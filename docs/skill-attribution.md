# Skill Attribution

This repo includes third-party skills and adapted guidance from reviewed upstream repositories.

## Imported Sources

| Source | Commit | License | Imported Location | Notes |
| --- | --- | --- | --- | --- |
| `addyosmani/agent-skills` | `6ce029897d2b794940325fc7148774a6ec51111c` | MIT | `templates/skills/imported/agent-skills/` | Copied all 23 engineering lifecycle skills. |
| `OthmanAdi/planning-with-files` | `6f94643bd2b77dad9ac30b68ace14a536e2e5619` | MIT | `templates/skills/imported/planning-with-files/` | Copied canonical English skill with templates/scripts. |
| `udapy/rust-agentic-skills` | `447eee0e2380c593bfcd14f91211524a57a8db92` | MIT | `templates/skills/imported/rust-agentic-skills/` | Copied all 8 Rust-focused skills and references/scripts. |
| `phuryn/pm-skills` | `2b4e4dc1510eb4be06d10bb3196f4705aa30a929` | MIT | `templates/skills/imported/pm-skills/` | Copied selected non-duplicate product, analytics, GTM, and discovery skills. |
| `alirezarezvani/claude-skills` | `fcd4fa1b203a9a0dc44d2482af21adfb53b7a727` | MIT | `templates/skills/imported/claude-skills/` | Copied selected engineering/product skills that fill gaps. |

## Adapted Sources

| Source | Commit | License | Adapted Location | Notes |
| --- | --- | --- | --- | --- |
| `pbakaus/impeccable` | `1d5d745823aae7019044e8b0a621af4366dae224` | Apache-2.0 | `templates/skills/adapted/frontend-design-review/` | Condensed into a portable frontend review skill without importing executable live-mode scripts. |
| `OthmanAdi/planning-with-files` | `6f94643bd2b77dad9ac30b68ace14a536e2e5619` | MIT | `templates/skills/adapted/planning-files-lite/` | Condensed into a lightweight planning-files pattern for projects that do not want hooks/scripts. |

## Not Imported

| Source | Reason |
| --- | --- |
| `JimLiu/baoyu-skills` | No root license found in local clone. Discovery only until licensing is resolved. |
| `ComposioHQ/awesome-claude-skills` | No root license found in local clone; also a broad catalog. |
| `diegosouzapw/awesome-omni-skills` | Large catalog; use for discovery and taxonomy only. |
| `sickn33/antigravity-awesome-skills` | Large catalog; use for discovery and packaging reference only. |
| `VoltAgent/awesome-agent-skills` | Catalog only; no local `SKILL.md` files. |
| `agentskills/agentskills` | Format/spec reference, not a skill pack. |

## Attribution Practice

When importing or adapting future skills:

1. Review license and provenance first.
2. Record source repo, commit SHA, license, imported path, and notes here.
3. Copy upstream license into `templates/skills/imported/licenses/` when content is imported or adapted.
4. Prefer adapted skills when upstream content is too tool-specific or executable-heavy.
