# Infrastructure And OpenTofu Steering

## Scope

Use this guidance for infrastructure as code under `{{INFRA_ROOT}}`, including OpenTofu modules,
environment compositions, state backends, CI validation, and operator workflows.

Repository-specific `AGENTS.md` and closer-scoped steering take precedence over this reusable
template. Replace every `{{PLACEHOLDER}}` before treating the file as enforceable project policy.

## Ownership And Change Boundaries

### MUST

- Keep infrastructure ownership explicit by environment and lifecycle.
- Keep runtime application configuration separate from cloud-resource provisioning.
- Add shared modules only after at least two real consumers demonstrate the same lifecycle and
  interface; do not create speculative abstraction layers.
- Document provider, region, cost owner, recovery owner, and rollback boundary before the first
  resource-creating apply.

## Versions And Dependency Locks

### MUST

- Pin the OpenTofu runtime to `{{OPENTOFU_VERSION}}` and verify the local/CI binary against that
  pin.
- Constrain every provider deliberately and commit the provider lock file.
- Generate lock checksums for every supported local and CI platform:
  `{{PROVIDER_LOCK_PLATFORMS}}`.
- Review runtime and provider upgrades separately from functional infrastructure changes.

## State, Plans, And Secrets

### MUST

- Keep backend configuration partial: inject bucket, key, endpoint, account, and credentials only
  at runtime.
- Use a remote backend with encryption, locking, least-privilege credentials, and a documented
  recovery procedure for shared or durable infrastructure.
- Confirm the backend's actual locking, consistency, versioning, and recovery capabilities; do
  not infer S3-compatible services provide every AWS S3 feature.
- Keep state and plan encryption enabled when supported. Store encryption material outside the
  repository and outside the state it protects.
- Never commit `.terraform/`, state, plans, backend inputs, `.tfvars`, credentials, tokens, or
  secret-bearing bootstrap/user-data artifacts.
- Keep plan and apply credentials separate when the provider supports narrower scopes.

### MUST NOT

- Pass long-lived secrets through cloud-init/user-data or ordinary OpenTofu resource attributes
  when that would persist them in state.
- Print credentials, decrypted state, plaintext plans, or sensitive outputs in CI logs or review
  artifacts.

## Validation And CI

### MUST

- Provide a deterministic, credential-free static lane that runs formatting, backend-disabled
  initialization with the committed lock file, and validation:

  ```sh
  {{TOFU_FORMAT_COMMAND}}
  {{TOFU_INIT_OFFLINE_COMMAND}}
  {{TOFU_VALIDATE_COMMAND}}
  ```

- Keep static validation unable to contact a real backend or cloud provider.
- Pin CI actions by full commit SHA, use least-privilege job permissions, and disable persisted
  checkout credentials unless a job explicitly needs them.
- Never use `pull_request_target` to execute untrusted infrastructure changes with protected
  credentials.
- Path-scope infrastructure-only CI unless the check is guaranteed to exist for every protected
  branch event.
- Test orchestration and cleanup scripts without cloud access before enabling protected live
  gates.

### SHOULD

- Add lint, security scanning, native tests, and cost checks when their signal is stable and their
  policy is documented.
- Keep provider-backed integration tests isolated by collision-resistant resource/state names and
  prove cleanup.

## Plan, Apply, Destroy, And Recovery

### MUST

- Separate validation, plan, and apply stages. Apply only a reviewed plan or an equivalently
  protected immutable change set.
- Bind protected plans to a full commit SHA, verify that commit against the authorized ref, and
  record a digest of the encrypted plan before approval.
- Require protected environments and explicit human approval for durable or public resource
  changes.
- Serialize applies per state key and fail closed on lock contention.
- Emit only a sanitized resource action/address/count summary; never upload raw plan JSON,
  plaintext state, or a decrypted plan as review evidence.
- Back up encrypted state according to the backend's real recovery model before risky changes,
  then verify the recovery copy. Record an explicit no-existing-state result on first apply.
- Document force-unlock, rollback, disable, and break-glass procedures before they are needed.
- Record resource, cost, security, and external-smoke evidence after an apply.

### MUST NOT

- Run `apply`, `destroy`, state mutation, import, or force-unlock as part of ordinary static CI.
- Use `-auto-approve` for destructive operations or bypass a required review boundary.
- Treat a successful local validation or speculative plan as proof that resources exist or are
  operational.

## Network And Bootstrap Safety

### MUST

- Default ingress to deny and open only the documented protocol, port, source, and environment
  combination.
- Keep administrative access private or narrowly allowlisted, with a tested lockout-recovery path.
- Bound public-service resource usage and document abuse controls, monitoring, and a kill switch.
- Keep bootstrap idempotent and free of long-lived secrets; prefer runtime secret retrieval from a
  dedicated secret store.

## Review Evidence

Every infrastructure PR should report:

- runtime/provider versions and backend mode;
- risk category and expected resource actions;
- exact validation commands and results;
- whether any live plan/apply ran and under which protected environment;
- cost and exposure changes;
- rollback/recovery steps and remaining risk.
