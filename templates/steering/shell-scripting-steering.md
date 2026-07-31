# Shell And Repository Scripting Steering

## Scope

Use this guidance for reusable automation under `{{SCRIPTS_ROOT}}`, including CI, container, VM,
hook, bootstrap, release, and developer scripts.

Repository-specific instructions and closer-scoped guidance take precedence.

## When To Add A Script

Create a committed script when a task is repeated, easy to execute incorrectly, or important for a
quality gate, parity check, recovery path, or release workflow.

Keep one-off commands and personal aliases in local notes or documentation unless the repository
needs to support them repeatedly.

## Portability

- Prefer POSIX `sh` for CI, containers, VMs, hooks, and cross-machine automation.
- Use Bash or another shell only for concrete required features, and document the requirement.
- Treat BusyBox/Alpine behavior as the portability baseline when the script runs in minimal images.
- Prefer `[` over `[[`, `$(...)` over backticks, `case` for string branching, and `command -v` for
  binary detection.
- Avoid arrays, process substitution, `pipefail`, Bash-only parameter expansion, and GNU-only flags
  in POSIX scripts.

## Design

- Keep scripts small, composable, deterministic, and single-purpose.
- Prefer orchestrating existing package, build, and ecosystem commands over reimplementing them.
- Parse arguments explicitly, quote expansions, and avoid `eval` or shell-built command strings.
- Fail fast with actionable errors and concise step-oriented output.
- Document required environment variables and prerequisites without printing secret values.
- Keep destructive targets explicit and validated; do not derive them from broad globs or unresolved
  variables.
- Make cleanup reliable with traps where temporary files, locks, or background processes are used.

## Placement And Interfaces

- Put reusable scripts under `{{SCRIPTS_ROOT}}` or its documented CI subdirectory.
- Keep Make/package targets as thin, stable wrappers around versioned scripts when that is the
  repository convention.
- Preserve existing command names and exit semantics unless the change explicitly migrates them.
- Remove obsolete task-specific scripts after their supported replacement is established.

## Testing And Verification

- Run the shell parser for every supported shell.
- Run ShellCheck when available.
- Test success, invalid-input, missing-dependency, failure, and cleanup paths.
- Exercise shared scripts in the smallest representative CI/container environment when practical.

```sh
{{SHELL_SYNTAX_COMMAND}}
{{SHELL_LINT_COMMAND}}
{{SCRIPT_TEST_COMMAND}}
```

Report exact commands and any platform-specific behavior that remains unverified.
