# Language Steering Research — 2026-07-31

## Scope

This review strengthens the reusable steering for every language platform currently bundled by AI
Central:

- JavaScript and TypeScript;
- Kotlin/JVM and Gradle;
- Rust and Cargo;
- POSIX shell.

Angular, Payload CMS, frontend design, and OpenTofu remain separate framework, domain, or platform
profiles. Go, Python, and other languages should receive their own researched profiles rather than
being inferred from unrelated project context.

The templates are original, domain-neutral guidance informed by primary documentation. They do not
copy product architecture, business terminology, commands, paths, or framework choices from the
projects previously reviewed.

## Shared Enforcement Model

Each language template now uses the same policy shape:

- `must` and `must not` are enforceable defaults;
- exceptions require a narrow scope and a documented reason;
- toolchain and dependency inputs must be reproducible;
- warnings, formatting, linting, tests, and builds are explicit quality gates;
- public APIs and cross-process boundaries receive stricter review than private implementation;
- untrusted input is validated at entry points and resource consumption is bounded;
- concurrency has explicit ownership, cancellation, failure, and shutdown behavior;
- optimization follows measurement and preserves correctness;
- project commands remain placeholders rather than invented universal commands.

This is intentionally strict without prescribing a single application architecture. A repository
can customize a template, but its local steering should record any relaxed rule and the reason.

## JavaScript And TypeScript

Primary sources reviewed:

- [TypeScript `noUncheckedIndexedAccess`](https://www.typescriptlang.org/tsconfig/noUncheckedIndexedAccess.html)
- [TypeScript `exactOptionalPropertyTypes`](https://www.typescriptlang.org/tsconfig/exactOptionalPropertyTypes.html)
- [TypeScript declaration-file do's and don'ts](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html)
- [typescript-eslint shared configurations](https://typescript-eslint.io/users/configs/)
- [Node.js ECMAScript modules](https://nodejs.org/api/esm.html)
- [Node.js error handling](https://nodejs.org/api/errors.html)
- [`npm ci`](https://docs.npmjs.com/cli/v12/commands/npm-ci/)

Decisions promoted into the template:

- strict TypeScript plus unchecked-index, exact-optional, unknown-catch, and override checks;
- no unbounded `any`, blanket suppression, ignored promises, or ambiguous ESM behavior;
- runtime validation at network, storage, environment, and serialization boundaries;
- explicit async ownership, cancellation, backpressure, cleanup, and error propagation;
- frozen lockfile installs and explicit runtime/module-system declarations.

The profile is separate from `base`. Guided setup detects it from `package.json` or JavaScript and
TypeScript source. Angular, frontend-design, and Payload profiles also install it when selected
directly because those profiles depend on the language baseline.

## Kotlin/JVM And Gradle

Primary sources reviewed:

- [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html)
- [Kotlin API backward-compatibility guidance](https://kotlinlang.org/docs/api-guidelines-backward-compatibility.html)
- [Kotlin coroutines guide](https://kotlinlang.org/docs/coroutines-guide.html)
- [Gradle build best practices](https://docs.gradle.org/current/userguide/best_practices.html)
- [Gradle dependency locking](https://docs.gradle.org/current/userguide/dependency_locking.html)
- [Gradle dependency verification](https://docs.gradle.org/current/userguide/dependency_verification.html)
- [Oracle Secure Coding Guidelines for Java SE](https://www.oracle.com/java/technologies/javase/seccodeguide.html)

Decisions promoted into the template:

- wrapper and toolchain alignment, stable dependency resolution, locking, and verification;
- immutable-first Kotlin, explicit null handling, narrow visibility, and meaningful domain types;
- coroutine scope ownership, cancellation propagation, dispatcher policy, and bounded concurrency;
- deterministic resource cleanup and careful Java serialization, JNI, reflection, and process edges;
- compatibility validation for published APIs and layered tests across JVM boundaries.

## Rust And Cargo

Primary sources reviewed:

- [Clippy usage](https://doc.rust-lang.org/stable/clippy/usage.html)
- [Cargo lints](https://doc.rust-lang.org/stable/cargo/reference/lints.html)
- [Cargo `rust-version`](https://doc.rust-lang.org/stable/cargo/reference/rust-version.html)
- [Cargo features](https://doc.rust-lang.org/stable/cargo/reference/features.html)
- [Rust Reference: the `unsafe` keyword](https://doc.rust-lang.org/stable/reference/unsafe-keyword.html)

Decisions promoted into the template:

- explicit edition, minimum supported Rust version, lockfile policy, and workspace lint inheritance;
- `rustfmt`, Clippy, documentation, tests, features, and MSRV as deliberate gates;
- narrow visibility, ownership-first APIs, typed failures, and controlled cloning/allocation;
- small, reviewed unsafe regions with written invariants and explicit unsafe operations;
- additive features, bounded input and concurrency, and measured performance work.

The template deliberately does not enable the entire Clippy `restriction` group. Individual lints
may be selected when they express a documented repository policy.

## POSIX Shell

Primary sources reviewed:

- [POSIX shell command language](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html)
- [ShellCheck SC2086: quote expansions](https://www.shellcheck.net/wiki/SC2086)
- [ShellCheck SC2155: separate declaration and command substitution](https://www.shellcheck.net/wiki/SC2155)

Decisions promoted into the template:

- declare the interpreter and do not use Bash syntax under `/bin/sh`;
- quote expansions, preserve argument boundaries, and avoid `eval` and string-built commands;
- handle expected failures explicitly instead of relying on `set -e` as the only error strategy;
- validate destructive targets, use private temporary paths, and guarantee cleanup with traps;
- lint, syntax-check, test, and exercise supported shell/runtime environments.

Shell remains an explicit profile. A few incidental scripts do not necessarily justify imposing
repository-wide shell policy.

## Follow-Up Criteria

A future language profile should meet the same bar before being bundled:

1. review current primary language, toolchain, package-manager, and security documentation;
2. distinguish universal language safety from framework or product architecture;
3. define strict defaults, scoped exceptions, placeholders, and executable verification gates;
4. add detector, scaffold, link-mode, idempotency, and non-cross-install tests;
5. document the promotion rationale in `docs/reuse-candidates.md`.
