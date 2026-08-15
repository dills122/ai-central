# .NET Steering Research — 2026-08-15

## Outcome

Promote seven composable profiles:

| Profile | Role | Automatic signals |
| --- | --- | --- |
| `dotnet-csharp` | Shared C#/.NET, SDK, MSBuild, API, async, security, dependency, and test baseline | C# source, projects/solutions, `global.json`, or shared build files |
| `dotnet-aspnetcore` | HTTP contracts, hosting, security, resilience, health, and integration tests | Web SDK or ASP.NET Core framework reference |
| `dotnet-efcore` | Context ownership, queries, transactions, migrations, and provider-realistic tests | EF Core package reference |
| `dotnet-orleans` | Grain scheduling, delivery, persistence, serialization, lifecycle, and multi-silo tests | Orleans package reference |
| `dotnet-aspire` | AppHost, ServiceDefaults, resources, secrets, telemetry, and deployment validation | Aspire hosting/AppHost signal |
| `dotnet-opentelemetry` | Signal ownership, conventions, cardinality, privacy, export, and propagation | OpenTelemetry package reference |
| `dotnet-grpc` | Protobuf compatibility, deadlines, retries, channels, streaming, and interoperability | `.proto` or gRPC/protobuf package signal in a .NET repository |

Each specialized profile composes with `dotnet-csharp`; direct scaffolding installs the baseline
automatically. Detection stays additive, so a service can receive exactly the framework profiles its
project references justify.

## Primary Sources

The templates are newly normalized guidance, not copied documentation. The review used primary
maintainer documentation and repositories:

### C# And .NET

- [.NET runtime coding style](https://github.com/dotnet/runtime/blob/main/docs/coding-guidelines/coding-style.md)
- [C# language versioning](https://learn.microsoft.com/en-us/dotnet/csharp/versioning)
- [`global.json` SDK selection](https://learn.microsoft.com/en-us/dotnet/core/tools/global-json)
- [.NET SDK MSBuild properties](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props)
- [Analyzer configuration](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/configuration-files)
- [.NET library compatibility rules](https://learn.microsoft.com/en-us/dotnet/core/compatibility/library-change-rules)
- [NuGet Central Package Management](https://learn.microsoft.com/en-us/nuget/consume-packages/central-package-management)
- [Package lock files](https://learn.microsoft.com/en-us/nuget/consume-packages/package-references-in-project-files#locking-dependencies)
- [NuGet package auditing](https://learn.microsoft.com/en-us/nuget/concepts/auditing-packages)
- [BinaryFormatter security guidance](https://learn.microsoft.com/en-us/dotnet/standard/serialization/binaryformatter-security-guide)

### Orleans

- [Orleans best practices](https://learn.microsoft.com/en-us/dotnet/orleans/resources/best-practices)
- [Request scheduling](https://learn.microsoft.com/en-us/dotnet/orleans/grains/request-scheduling)
- [External tasks and grains](https://learn.microsoft.com/en-us/dotnet/orleans/grains/external-tasks-and-grains)
- [Cancellation tokens](https://learn.microsoft.com/en-us/dotnet/orleans/grains/cancellation-tokens)
- [Messaging delivery guarantees](https://learn.microsoft.com/en-us/dotnet/orleans/implementation/messaging-delivery-guarantees)
- [Grain persistence](https://learn.microsoft.com/en-us/dotnet/orleans/grains/grain-persistence/)
- [Serialization code generation](https://learn.microsoft.com/en-us/dotnet/orleans/grains/code-generation)
- [Grain versioning](https://learn.microsoft.com/en-us/dotnet/orleans/grains/grain-versioning/grain-versioning)
- [Timers and reminders](https://learn.microsoft.com/en-us/dotnet/orleans/grains/timers-and-reminders)
- [Kubernetes deployment](https://learn.microsoft.com/en-us/dotnet/orleans/deployment/kubernetes)
- [Aspire Orleans integration](https://learn.microsoft.com/en-us/dotnet/aspire/frameworks/orleans)

### ASP.NET Core, EF Core, Aspire, And OpenTelemetry

- [ASP.NET Core fundamentals](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/)
- [ASP.NET Core security](https://learn.microsoft.com/en-us/aspnet/core/security/)
- [EF Core DbContext lifetime and threading](https://learn.microsoft.com/en-us/ef/core/dbcontext-configuration/)
- [EF Core performance guidance](https://learn.microsoft.com/en-us/ef/core/performance/)
- [EF Core migrations overview](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/)
- [Aspire AppHost overview](https://learn.microsoft.com/en-us/dotnet/aspire/fundamentals/app-host-overview)
- [Aspire service defaults](https://learn.microsoft.com/en-us/dotnet/aspire/fundamentals/service-defaults)
- [Aspire integrations](https://learn.microsoft.com/en-us/dotnet/aspire/fundamentals/integrations-overview)
- [.NET observability with OpenTelemetry](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/observability-with-otel)
- [OpenTelemetry .NET documentation](https://opentelemetry.io/docs/languages/dotnet/)
- [OpenTelemetry .NET metric best practices](https://opentelemetry.io/docs/languages/dotnet/metrics/best-practices/)

### gRPC

- [gRPC on .NET overview](https://learn.microsoft.com/en-us/aspnet/core/grpc/)
- [Versioning gRPC services](https://learn.microsoft.com/en-us/aspnet/core/grpc/versioning)
- [Deadlines and cancellation](https://learn.microsoft.com/en-us/aspnet/core/grpc/deadlines-cancellation)
- [Transient-fault retries](https://learn.microsoft.com/en-us/aspnet/core/grpc/retries)
- [gRPC performance practices](https://learn.microsoft.com/en-us/aspnet/core/grpc/performance)
- [.NET gRPC client guidance](https://learn.microsoft.com/en-us/aspnet/core/grpc/client)

## Upstream Skill Review

Reviewed `dotnet/skills` from `https://github.com/dotnet/skills` at commit
`7c1ae3fdf2eb64b758bb3a7b7f92cad3fbd95868` on 2026-08-15. The repository is MIT licensed and is
maintained as an official .NET team skill collection.

Imported verbatim skill content, with the upstream MIT license added to each packaged skill:

- `dotnet-test/skills/run-tests`
- `dotnet-test/skills/platform-detection`
- `dotnet-test/skills/filter-syntax`
- `dotnet-msbuild/skills/directory-build-organization`
- `dotnet-msbuild/skills/msbuild-antipatterns`
- `dotnet-msbuild/skills/binlog-generation`
- `dotnet-msbuild/skills/binlog-failure-analysis`

These form the detected `dotnet` bundle. Test support skills were retained together because the
run-test workflow delegates platform and filter decisions to them. The binlog analysis skill keeps
its documented text-log fallback when its preferred MCP server is unavailable.

Also reviewed `github/awesome-copilot` at commit
`a80885b76044550770f60f360f8a0e5ae3524a31` as a discovery catalog. Its broad prompts and
instructions were not imported: they do not provide one coherent, strict, framework-composable
.NET policy, and importing the catalog would add overlap and activation noise.

## Decisions And Boundaries

- Do not hardcode the newest SDK, target framework, C# version, test runner, or framework version.
  Repositories own support policy through checked-in configuration.
- Keep durable rules in steering profiles and procedural diagnostics in skills.
- Do not impose Clean Architecture, DDD, CQRS, a test framework, a database provider, a cloud, or one
  endpoint style as universal .NET policy.
- Do not treat Orleans retries as exactly-once delivery, `ConfigureAwait(false)` as safe default grain
  code, runtime EF migrations as a production default, Aspire local resources as production
  infrastructure, or telemetry as permission to collect sensitive/high-cardinality data.
- Do not select gRPC from a `.proto` file unless the same repository also has a .NET signal.
- Preserve non-overwriting scaffold behavior and make every framework profile independently selectable.

## Validation Requirements

- Shell syntax and catalog JSON must parse.
- Every .NET steering template must contain scope, testing, and verification sections.
- Direct specialization scaffolding must install the C#/.NET baseline and no sibling specialization.
- Detection must select all matching .NET profiles and the `dotnet` bundle from representative project
  files, while a protobuf-only non-.NET repository remains stack-neutral.
- Copy and link modes must be idempotent and preserve project-owned files.
- The `dotnet` bundle and generated APM manifest must contain the seven reviewed skills and licenses.
- Bundle unions, exact `--skills` additions, `--skip-skills` exclusions, and link-mode `--sync` must
  treat the installed `dotnet-*` names as part of the authoritative configurable skill catalog.
