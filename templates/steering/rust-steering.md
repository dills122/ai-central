# Rust Steering

## Scope

Use this guidance for Rust code under `{{RUST_ROOT}}`.

Repository-specific `AGENTS.md`, crate documentation, and closer-scoped steering take precedence.
Replace every placeholder before treating this file as enforceable project policy.

## Toolchain And Dependencies

- Keep the Rust edition and toolchain explicit. Do not change either in an incidental feature PR.
- Use Cargo and the repository's pinned toolchain or lockfile rather than ad hoc compiler commands.
- Keep formatting on `cargo fmt` and linting on the repository's configured Clippy policy.
- Add dependencies only after checking the workspace and standard ecosystem for an existing supported
  implementation. Review network, codec, crypto, async, FFI, and process dependencies carefully.
- Keep dependency features narrow when the project intentionally needs only a smaller surface.

## Architecture And Contracts

- Keep domain behavior separate from transport, persistence, UI, FFI, and host adapters.
- Keep public exports narrow and domain-oriented; prefer `pub(crate)` for internal cross-module use.
- Define cross-language or cross-service contracts from one source of truth and generate downstream
  artifacts when practical.
- Never hand-edit generated bindings or schemas. Change the source contract, regenerate, and run the
  drift check.
- Before adding a parser, encoder, decoder, or serializer, find and extend the repository's existing
  supported implementation instead of creating a parallel one.

## API And Error Design

- Follow idiomatic Rust naming and conversion conventions.
- Use explicit enums and value types for states, policies, units, and identifiers.
- Return typed `Result` values for recoverable failures.
- Do not use `unwrap`, `expect`, or `panic!` on user-controlled, network, protocol, or persisted input
  paths.
- Convert rich internal errors into stable boundary errors only at the adapter edge.
- Keep error classification deterministic and avoid exposing secrets or sensitive internal details.

## Untrusted Input And Resource Bounds

- Validate lengths before slicing, indexing, allocating, converting, or mutating state.
- Use checked or saturating arithmetic when offsets, lengths, counters, or timers can overflow.
- Bound payloads, decoded output, recursion, redirects, retries, queues, collections, and process
  execution.
- Reject malformed or oversized input deterministically; do not silently truncate semantic data.
- Keep failure paths safe for partial reads, invalid encodings, unknown variants, and interrupted work.
- Disallow `unsafe` by default. Any exception requires explicit review, minimal scope, documented
  invariants with a `SAFETY` comment, and targeted tests.

## Concurrency And I/O

- Preserve deterministic state transitions and ordering where correctness depends on them.
- Keep blocking work off async executors through the repository's established boundary.
- Do not introduce or replace an async runtime incidentally.
- Bound task creation, channels, retries, timeouts, and shutdown behavior.
- Make cancellation and cleanup explicit for files, sockets, child processes, and temporary data.

## Duplication Discipline

- Check the current module and sibling modules before adding near-identical logic.
- Extract a shared helper when duplicate logic lives inside the boundary already being changed.
- Prefer a small shared internal crate over copying genuinely shared logic across workspace crates.
- Generate cross-language constants and contract types from a canonical source rather than
  hand-maintaining parallel tables.

## Testing

Prioritize:

- focused unit and state-transition tests;
- valid, invalid, truncated, and boundary-value parser/codec tests;
- contract generation and drift checks;
- deterministic fixture and replay tests;
- integration tests at adapter boundaries;
- property-based or fuzz tests for byte parsers and complex state machines when valuable.

Default tests should not require live network access. Treat fixture changes as behavior changes.

## Verification

Run the smallest reliable checks for the changed crate, then the broader gate:

```sh
{{RUST_FORMAT_COMMAND}}
{{RUST_LINT_COMMAND}}
{{RUST_TEST_COMMAND}}
{{RUST_CHECK_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
