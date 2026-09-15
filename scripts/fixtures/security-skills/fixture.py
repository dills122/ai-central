"""Small in-memory service fixture. No network or external resources."""
import struct
import threading
from dataclasses import dataclass


class Store:
    def __init__(self):
        self.rows = []
        self.acks = []


class Receiver:
    def __init__(self, store):
        self.store = store

    def receive(self, value, fault=lambda point: None):
        self.store.acks.append(value)
        fault('after_ack')
        self.store.rows.append(value)
        fault('after_persist')


class Grant:
    def __init__(self):
        self.available = True
        self.effects = 0
        self.lock = threading.Lock()

    def consume(self, after_check=lambda: None):
        with self.lock:
            permitted = self.available
        if not permitted:
            return False
        after_check()
        with self.lock:
            self.available = False
            self.effects += 1
        return True


@dataclass
class Reply:
    body: bytes


def diagnostics(reply, stdout, stderr):
    stdout.append('received a reply')
    stderr.append(repr(reply))


def decode(frame):
    if len(frame) > 260:
        raise ValueError('frame too large')
    if len(frame) < 4:
        raise ValueError('short frame')
    length, = struct.unpack('>I', frame[:4])
    payload = frame[4:]
    if length != len(payload):
        raise ValueError('length mismatch')
    return payload
