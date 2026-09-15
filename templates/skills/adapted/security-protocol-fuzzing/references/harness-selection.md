# Harness Selection

Use existing repository pins and commands before adding tools. Inspect installed
versions and platform support; do not install a different toolchain automatically.

| Target | Starting point | Evidence boundary |
| --- | --- | --- |
| Go parser or state operation | Native Go fuzz test with a seed corpus | Run the regression corpus in ordinary tests; cap fuzz duration and concurrency explicitly |
| Rust parser or library | Existing cargo-fuzz/libFuzzer target, or the project's property-test framework | Check required compiler, sanitizer and supported platform before running; a property test is not automatically coverage-guided fuzzing |
| C/C++ or native FFI | Existing libFuzzer/AFL++ harness with applicable sanitizers | Record which native components were actually instrumented; memory diagnostics do not check authorization semantics |
| Runtime without an established fuzz engine | Bounded generated cases around the real decoder/state machine | Label deterministic/property sampling honestly; preserve seeds and operation sequences |

## State And Budget Traps

Model and real-adapter tests answer different questions. A model can exhaust a small
schedule space but cannot establish that production persistence or locking matches
it. Re-run selected counterexamples through the actual implementation.

Track transport bytes, decoded bytes, allocation, parse depth, crypto work and
retained-state size separately when relevant. A wire-length check may not bound a
declared allocation; an operation-count limit may not bound expensive individual
operations. Keep watchdog ownership outside a target that can hang.

For async protocols, include partial exchange, cancellation, duplicate response,
expiry and restart. Save the operation sequence and clock/random seed with a
failure; the last malformed frame alone may not reproduce it.

## Primary Tool Documentation

- [Go fuzzing](https://go.dev/doc/security/fuzz/)
- [Rust Fuzz Book: cargo-fuzz](https://rust-fuzz.github.io/book/cargo-fuzz.html)
- [LLVM libFuzzer](https://llvm.org/docs/LibFuzzer.html)

These are version-sensitive tool references, not a requirement to enable every tool.
