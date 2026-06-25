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
| `antfu/skills` | `50deaeb269d80d92db7a2c5a677290309ae307fc` | MIT | `templates/skills/imported/antfu-skills/` | Copied selected frontend/toolchain and Vue ecosystem skills; excluded personal `antfu` and `tsdown`. |
| `addyosmani/web-quality-skills` | `7b59d48aaf1f793935002f4998dfccc656f40839` | MIT | `templates/skills/imported/web-quality-skills/` | Copied all 6 web quality skills. |
| `antonbabenko/terraform-skill` | `b59d2be9ff4db8f835c8459e05e325ba11e3a21f` | Apache-2.0 | `templates/skills/imported/terraform-skill/` | Copied Terraform/OpenTofu skill with references. |
| `softaworks/agent-toolkit` | `3027f20f3181758385a1bb8c022d4041dfb4de84` | MIT | `templates/skills/imported/agent-toolkit/` | Copied selected source skills only; excluded duplicated `dist/` copies and provider/social/persona skills. |
| `JuliusBrussee/caveman` | `25d22f864ad68cc447a4cb93aefde918aa4aec9f` | MIT | `templates/skills/imported/caveman/` | Copied portable skills and agent presets; installer exposes portable skills through the `brevity` bundle. |

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
| `trailofbits/skills` | CC BY-SA 4.0. High-value security reference, but not imported until this repo has an explicit share-alike strategy. |
| `heilcheng/awesome-agent-skills` | Catalog only; no local `SKILL.md` files. |
| `microsoft/skills` | Reviewed as an MIT-licensed Azure/Microsoft profile candidate; not imported because it is large and vendor-specific. |

## Attribution Practice

When importing or adapting future skills:

1. Review license and provenance first.
2. Record source repo, commit SHA, license, imported path, and notes here.
3. Copy upstream license into `templates/skills/imported/licenses/` when content is imported or adapted.
4. Prefer adapted skills when upstream content is too tool-specific or executable-heavy.
