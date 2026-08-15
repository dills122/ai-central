# Scaffold Profiles

The scaffold script installs non-overwriting AI context into a target project.

```sh
./scripts/scaffold-ai-context.sh /path/to/project --profile base
```

Use `--mode link` to symlink reusable steering while still copying repo-specific files:

```sh
./scripts/scaffold-ai-context.sh /path/to/project --profile frontend-design --mode link
```

## Base

Installs:

- `AGENTS.md`
- `.codex/steering/repository-steering.md`
- `.codex/steering/testing-quality-gates-steering.md`

Use for stack-neutral repository policy. Language profiles are installed separately so a pure Rust,
Kotlin, or infrastructure project does not receive unrelated JavaScript rules.

## JavaScript And TypeScript

Includes everything from `base`, plus:

- `.codex/steering/javascript-typescript-steering.md`

Use for JavaScript, TypeScript, Node.js, browser, and mixed web repositories. Guided setup detects
this profile from `package.json` and JavaScript/TypeScript source files. Replace its runtime,
source-root, and verification placeholders before treating it as project policy.

This replaces the former `javascript-esm-steering.md` template. Existing copied or linked instances
of that file are not deleted automatically; review and remove them after installing the new profile.

## Angular

Includes everything from `base` and the JavaScript/TypeScript language profile, plus:

- `.codex/steering/angular-steering.md`

Use for Angular apps and Angular monorepo packages.

## C# And .NET

Includes everything from `base`, plus:

- `.codex/steering/dotnet-csharp-steering.md`

Use for C# applications, services, libraries, tools, and .NET solutions. Guided setup detects C#
source, project/solution files, `global.json`, and shared MSBuild files. Replace the root and command
placeholders before enforcement.

The specialist .NET profiles below automatically include this baseline when scaffolded directly.

## ASP.NET Core

Adds `.codex/steering/dotnet-aspnetcore-steering.md` for Web SDK or ASP.NET Core projects. It covers
HTTP contracts, boundary validation, middleware and DI lifetimes, security/abuse limits, outbound
resilience, operations, and hosted integration tests.

## Entity Framework Core

Adds `.codex/steering/dotnet-efcore-steering.md` when an EF Core package reference is detected. It
covers `DbContext` ownership, query shape, transactions, optimistic concurrency, reviewed migrations,
deployment boundaries, and tests against the supported provider.

## .NET Orleans

Adds `.codex/steering/dotnet-orleans-steering.md` when an Orleans reference is detected. It covers
grain identity, scheduling and reentrancy, cancellation and delivery semantics, persistence and
serialization evolution, lifecycle, rolling deployment, observability, and multi-silo tests.

## .NET Aspire

Adds `.codex/steering/dotnet-aspire-steering.md` for Aspire AppHost/hosting projects. It covers the
application model, ServiceDefaults, references and wait relationships, secrets, development versus
production boundaries, telemetry, resource tests, and deployment-artifact review.

## OpenTelemetry For .NET

Adds `.codex/steering/dotnet-opentelemetry-steering.md` when OpenTelemetry packages are referenced.
It covers signal ownership, semantic conventions, cardinality and privacy, sampling/export limits,
context propagation, and telemetry contract tests.

## gRPC For .NET

Adds `.codex/steering/dotnet-grpc-steering.md` for .NET projects containing protobuf contracts or
gRPC/protobuf package references. It covers field-number compatibility, presence and enums, deadlines,
cancellation, retry safety, channel reuse, bounded streaming, TLS/operations, and interoperability.

## Frontend Design

Includes everything from `base` and the JavaScript/TypeScript language profile, plus:

- `.codex/steering/frontend-design-steering.md`

Use for user-facing apps, dashboards, landing pages, frontend components, and design-system work.

## Kotlin/JVM

Includes everything from `base`, plus:

- `.codex/steering/kotlin-jvm-steering.md`

Use for Kotlin/JVM services, libraries, CLI tools, and applications built with Gradle. Replace the
Kotlin root, JVM version, and verification command placeholders before treating the installed file
as project policy.

## Rust

Includes everything from `base`, plus:

- `.codex/steering/rust-steering.md`

Use for Rust crates and workspaces. Guided setup selects this profile and the existing `rust` skill
bundle when it detects `Cargo.toml`.

## Shell And Scripting

Includes everything from `base`, plus:

- `.codex/steering/shell-scripting-steering.md`

Use explicitly for repositories with substantial shared shell, CI, container, VM, hook, bootstrap,
or release automation. Replace the command and scripts-root placeholders before enforcing it.

## Payload

Includes everything from `base` and the JavaScript/TypeScript language profile, plus:

- `.cursor/rules/payload-overview.md`

Use for Payload CMS projects or app folders.

## Infrastructure And OpenTofu

Includes everything from `base`, plus:

- `.codex/steering/infrastructure-opentofu-steering.md`

Use for repositories with OpenTofu/Terraform compositions, modules, remote state, provider-backed
CI, or infrastructure operator workflows. Replace its project, version, platform, and command
placeholders before treating the installed file as enforceable policy.

The profile supplies durable repository steering. Pair it with the opt-in `infra` skill bundle
when agents also need the detailed Terraform/OpenTofu diagnosis and implementation workflow.

## Idempotency

The script skips existing files. It does not merge or overwrite.

For existing projects, inspect skipped files manually before deciding whether to copy template changes across.
