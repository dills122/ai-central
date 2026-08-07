---
name: github-keychain-auth
description: Use the macOS Keychain-backed GitHub credential safely for GitHub CLI, Git, and API operations. Use when GitHub authentication fails, an inherited GH_TOKEN or GITHUB_TOKEN may be stale, a task needs the routinely configured Keychain credential, or an agent must verify GitHub access without exposing credential bytes.
---

# GitHub Keychain Auth

Use GitHub CLI's existing macOS Keychain integration. Treat credential availability as authentication only; the user's task still defines the authorized repository and operation.

## Safe Workflow

1. Do not inspect either token environment variable. Remove both only for the GitHub command so stale inherited values do not take precedence over the account already configured in GitHub CLI:

   ```sh
   env -u GH_TOKEN -u GITHUB_TOKEN gh auth status --hostname github.com
   ```

2. Verify only non-secret identity metadata when a live API check is useful:

   ```sh
   env -u GH_TOKEN -u GITHUB_TOKEN gh api user --jq '{login: .login, id: .id}'
   ```

3. Run each authorized `gh` command with the same two-variable override:

   ```sh
   env -u GH_TOKEN -u GITHUB_TOKEN gh pr view NUMBER --repo OWNER/REPO
   ```

4. Use ordinary `git fetch`, `git pull`, and `git push` commands. Let the configured Git credential helper and Keychain resolve credentials; do not add authentication headers or token-bearing remote URLs. Do not print an existing remote URL unless it is already known to be credential-free.

5. If authentication still fails after removing the inherited variables, stop. Report that the stored GitHub authentication is missing, invalid, or unavailable. Ask the user to reauthenticate or rotate it; do not extract it as a workaround.

## Secret-Safety Invariants

- Never run `gh auth token`, `security find-generic-password -w`, `printenv GH_TOKEN`, `printenv GITHUB_TOKEN`, or any command that prints the credential.
- Never echo, log, paste, summarize, copy, or persist token bytes in chat, tool output, shell history, files, URLs, issue or pull-request bodies, artifacts, or another task.
- Never pass token bytes to a sub-agent or another chat. Pass only this instruction: use Keychain-backed GitHub authentication and unset stale `GH_TOKEN` and `GITHUB_TOKEN` for each `gh` command.
- Never store the token in repository configuration, skill files, steering, scripts, fixtures, or examples.
- Never use the GitHub credential for a non-GitHub service or for repositories and mutations outside the user's authorized scope.
- Request sandbox or network approval for the intended GitHub command when required, not for credential extraction.
- Run `gh auth login`, `gh auth logout`, `gh auth setup-git`, or credential rotation only when the user explicitly authorizes that credential-state change.

## Handoff

Report authentication results using status and non-secret account or repository metadata only. If another task needs GitHub access, include the authorized repository, pull request or issue, branch, intended mutation, completed verification, current work status, and remaining work. Tell it to invoke `$github-keychain-auth` and repeat the `env -u GH_TOKEN -u GITHUB_TOKEN gh ...` command pattern so the handoff remains useful if skill discovery is delayed. Do not send it a credential.
