"""Bounded stdlib-only model checks. No network; fixture remains unchanged."""
import contextlib
import hashlib
import importlib.util
import io
import json
import platform
import random
import struct
import sys
import threading
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('fixture', ROOT / 'fixture.py')
fixture = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = fixture
spec.loader.exec_module(fixture)


def recovery():
    def legal(store):
        return all(store.rows.count(v) >= store.acks.count(v) for v in set(store.acks))

    cases = []
    for fault_point in ['before_call', 'after_ack', 'after_persist', 'none']:
        store = fixture.Store()
        receiver = fixture.Receiver(store)

        def fault(point):
            if point == fault_point:
                raise RuntimeError('synthetic interruption')

        if fault_point != 'before_call':
            try:
                receiver.receive('synthetic-value', fault)
            except RuntimeError:
                pass
        del receiver
        reopened = fixture.Receiver(store)
        observed = {'rows': len(store.rows), 'acks': len(store.acks)}
        verdict = legal(store)
        before_valid = (len(store.rows), len(store.acks))
        reopened.receive('unrelated-valid')
        assert len(store.rows) == before_valid[0] + 1
        assert len(store.acks) == before_valid[1] + 1
        reopened.receive('synthetic-value')
        cases.append({'fault': fault_point, 'reopened_counts': observed, 'invariant_holds': verdict,
                      'subsequent_valid_operation': True,
                      'after_valid_then_same_value_retry': {'rows': len(store.rows), 'acks': len(store.acks)}})
    assert [c['invariant_holds'] for c in cases] == [True, False, True, True]
    control = fixture.Store()
    control.acks.append('control')
    assert not legal(control)
    control.rows.append('control')
    assert legal(control)
    return {'cases': cases, 'negative_and_positive_oracle_controls': True}


def races():
    def legal(grant):
        return grant.effects <= 1

    grant = fixture.Grant()
    barrier = threading.Barrier(2, timeout=0.5)
    results, errors = [], []

    def worker():
        try:
            results.append(grant.consume(lambda: barrier.wait()))
        except Exception as exc:
            errors.append(type(exc).__name__)

    threads = [threading.Thread(target=worker, daemon=True) for _ in range(2)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join(timeout=1)
    assert not any(t.is_alive() for t in threads), 'owned thread did not terminate'
    assert not errors, errors
    assert results == [True, True] and grant.effects == 2 and not grant.available
    assert not legal(grant)  # Supplied defective model is the controlled negative fixture.
    assert grant.consume() is False and grant.effects == 2
    sequential = []
    for ordering in [('A', 'B'), ('B', 'A')]:
        valid = fixture.Grant()
        outcomes = [(actor, valid.consume()) for actor in ordering]
        assert [value for _, value in outcomes] == [True, False] and valid.effects == 1
        assert legal(valid)
        sequential.append({'ordering': ordering, 'outcomes': outcomes, 'effects': valid.effects})
    return {'overlap': {'returns': results, 'effects': grant.effects, 'available': grant.available},
            'sequential_controls': sequential, 'workers_exited': True,
            'scope_identity_and_cancellation': 'not supported by fixture API'}


def secrets():
    # Intentionally authorized expected-value buffers; never retained in observations.
    canaries = [('ascii', b'SYNTHETIC_NO_AUTH_RIGHTS_92847'), ('binary', bytes([255, 0, 129, 39, 92]))]
    verdicts = []

    def collect(producer, reply):
        out, err = [], []
        native_out, native_err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(native_out), contextlib.redirect_stderr(native_err):
            producer(reply, out, err)
        channels = {'declared_stdout': '\n'.join(out), 'declared_stderr': '\n'.join(err),
                    'python_stdout': native_out.getvalue(), 'python_stderr': native_err.getvalue()}
        assert sum(len(value.encode()) for value in channels.values()) < 65536
        return channels

    def scan(channels, value):
        representations = [repr(value), repr(value)[2:-1]]
        if value.isascii():
            representations.append(value.decode('ascii'))
        return {channel: any(rep and rep in text for rep in representations)
                for channel, text in channels.items()}

    for label, value in canaries:
        reply = fixture.Reply(value)
        channels = collect(fixture.diagnostics, reply)
        result = scan(channels, value)
        assert result['declared_stderr'] and not result['declared_stdout']
        assert reply.body == value and channels['declared_stdout'] == 'received a reply'
        def leaky(reply, stdout, stderr):
            stderr.append(repr(reply.body))
        def clean(reply, stdout, stderr):
            stdout.append('received a reply')
        assert scan(collect(leaky, reply), value)['declared_stderr']
        assert not any(scan(collect(clean, reply), value).values())
        verdicts.append({'secret_class': label, 'leaks_by_channel': result,
                         'authorized_accessor_preserved': True, 'controls_detected': True})
    return {'cases': verdicts, 'capture_completeness': 'established for synchronous list sinks and Python streams only',
            'scan': 'fail', 'empty_secret': 'not security-informative; not scanned'}


def protocols():
    rng = random.Random(42817)
    started = time.monotonic()
    failures, rejects, accepts = [], {}, 0
    seeds = [b'', b'\x00', b'\x00\x00\x00', struct.pack('>I', 1), struct.pack('>I', 0) + b'x']
    seeds += [struct.pack('>I', n) + bytes([65]) * n for n in [0, 1, 127, 128, 129, 130, 255, 256, 257]]

    def check(frame, decoder):
        try:
            payload = decoder(frame)
        except ValueError as exc:
            return 'reject', str(exc)
        legal = (len(frame) >= 4 and struct.unpack('>I', frame[:4])[0] == len(frame) - 4
                 and len(frame) - 4 <= 128 and payload == frame[4:])
        return ('accept' if legal else 'violation'), len(payload)

    # Controlled defective decoder fails the same oracle; valid input still reaches behavior.
    minimal = struct.pack('>I', 129) + b'A' * 129
    assert check(minimal, lambda frame: frame[4:])[0] == 'violation'
    assert check(struct.pack('>I', 1) + b'A', fixture.decode) == ('accept', 1)
    count = 0
    for count in range(1014):
        assert time.monotonic() - started < 2, 'campaign deadline exceeded'
        if count < len(seeds):
            frame = seeds[count]
        else:
            n = rng.randrange(0, 297)
            payload = rng.randbytes(n)
            declared = n if count % 2 else rng.randrange(0, 301)
            frame = struct.pack('>I', declared) + payload
        assert len(frame) <= 300
        outcome, info = check(frame, fixture.decode)
        if outcome == 'violation':
            failures.append(len(frame) - 4)
        elif outcome == 'reject':
            rejects[info] = rejects.get(info, 0) + 1
        else:
            accepts += 1
    assert failures and min(failures) == 129
    assert check(minimal, fixture.decode) == ('violation', 129)
    assert check(struct.pack('>I', 128) + b'A' * 128, fixture.decode) == ('accept', 128)
    (ROOT / 'oversized-frame.bin').write_bytes(minimal)
    return {'kind': 'deterministic seeds and PRNG sampling; not coverage-guided fuzzing', 'seed': 42817,
            'cases': count + 1, 'valid_accepts': accepts, 'rejects': rejects,
            'oversized_accepts': len(failures), 'minimum_violating_payload': min(failures),
            'minimized_regression': 'oversized-frame.bin', 'elapsed_seconds': time.monotonic() - started}


def main():
    before = hashlib.sha256((ROOT / 'fixture.py').read_bytes()).hexdigest()
    # Outer collectors start before synthetic values are created; inner collectors
    # own the list sinks and Python streams during each diagnostics call.
    creation_out, creation_err = io.StringIO(), io.StringIO()
    with contextlib.redirect_stdout(creation_out), contextlib.redirect_stderr(creation_err):
        secret_results = secrets()
    assert creation_out.getvalue() == '' and creation_err.getvalue() == ''
    results = {'revision': {'fixture_sha256': before,
                           'contract_sha256': hashlib.sha256((ROOT / 'CONTRACT.md').read_bytes()).hexdigest()},
               'platform': platform.platform(), 'python': sys.version,
               'budget': {'race_workers': 2, 'barrier_timeout_seconds': 0.5, 'join_timeout_seconds': 1,
                          'protocol_cases': 1014, 'protocol_input_bytes': 300, 'campaign_seconds': 2,
                          'capture_bytes': 65536, 'estimated_harness_retained_bytes': '<1 MiB',
                          'process_memory': 'not independently measured or enforced',
                          'artifact_bytes_limit': 32768},
               'recovery': recovery(), 'race': races(), 'secrets': secret_results, 'protocol': protocols()}
    assert hashlib.sha256((ROOT / 'fixture.py').read_bytes()).hexdigest() == before
    results['fixture_unchanged'] = True
    encoded = json.dumps(results, indent=2)
    assert len(encoded.encode()) < 32768
    (ROOT / 'evidence.json').write_text(encoded + '\n')
    print('Four model violations reproduced; valid and defective controls checked. See evidence.json.')


if __name__ == '__main__':
    main()
