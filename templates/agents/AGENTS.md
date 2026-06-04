# AGENTS

AI coding guidance for this repository.

## Purpose

This repository builds `{{PROJECT_NAME}}`.

Optimize for:

- `{{PRIORITY_1}}`
- `{{PRIORITY_2}}`
- small, explicit changes over broad refactors
- tests and documentation when behavior, contracts, setup, or commands change

## Architecture Boundaries

Primary areas:

- `{{AREA_1_PATH}}`: `{{AREA_1_RESPONSIBILITY}}`
- `{{AREA_2_PATH}}`: `{{AREA_2_RESPONSIBILITY}}`
- `{{AREA_3_PATH}}`: `{{AREA_3_RESPONSIBILITY}}`

When a change spans areas, preserve ownership boundaries and update shared contracts first.

## Contract-First Files

Treat these as interface contracts before implementation details:

- `{{CONTRACT_FILE_1}}`
- `{{CONTRACT_FILE_2}}`

If behavior changes, update the relevant contract and docs in the same change.

## Scope Control

- Keep changes localized to the requested behavior.
- Avoid unrelated refactors and generated artifact churn.
- Call out follow-up work separately from the current change.
- Do not change public interfaces, storage formats, route surfaces, or app names without explicit intent.

## Repository Conventions

- Follow existing formatting and linting config.
- Prefer existing helper APIs and local patterns.
- Add focused tests for behavior changes.
- Update docs when setup steps, commands, contracts, or workflows change.

## Useful Commands

- Install dependencies: `{{INSTALL_COMMAND}}`
- Lint: `{{LINT_COMMAND}}`
- Test: `{{TEST_COMMAND}}`
- Build: `{{BUILD_COMMAND}}`

## Branch And PR Metadata

- Use feature branches for behavior, contract, test, or documentation changes.
- Do not commit directly to `main`.
- When work is ready, provide:
  - branch name
  - PR title
  - PR summary
  - test evidence
