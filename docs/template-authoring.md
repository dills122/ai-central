# Template Authoring

Templates should be reusable, explicit, and easy to customize.

## Placeholders

Use double-brace placeholders for project-specific details:

- `{{PROJECT_NAME}}`
- `{{PRIMARY_STACK}}`
- `{{TEST_COMMAND}}`
- `{{BUILD_COMMAND}}`
- `{{CONTRACT_FILE_1}}`

Prefer placeholders over vague prose when a target project must supply a concrete value.

## Scope

Good templates:

- describe durable engineering expectations
- name boundaries and ownership
- tell agents when to update tests and docs
- avoid tool-specific quirks unless the file is for that tool

Avoid:

- product-specific roadmap details
- private repo names
- environment-specific hostnames
- commands that only work in one source project unless clearly labeled

## Promotion Checklist

- Source file is listed in `docs/inventory.md`.
- Reuse decision is documented in `docs/reuse-candidates.md`.
- Project-specific details are replaced with placeholders.
- Scaffold profile is updated only if the template should be installed by default.
