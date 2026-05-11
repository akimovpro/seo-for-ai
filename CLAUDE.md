# seo-for-ai — repo notes for agents working on this repo

This is a multi-target Claude / Codex / Cursor / Gemini / OpenCode plugin that
ships a single skill: `seo-for-ai`. The skill content lives in `skills/seo-for-ai/`.
Per-tool plugin manifests in `.claude-plugin/`, `.codex-plugin/`,
`.cursor-plugin/`, `gemini-extension.json`, and `.opencode/` all point at the
same `skills/` and `commands/` directories — never duplicate skill content.

## Layout

```
.claude-plugin/{plugin,marketplace}.json   # Claude Code
.codex-plugin/plugin.json                   # Codex CLI
.cursor-plugin/plugin.json                  # Cursor
gemini-extension.json + GEMINI.md           # Gemini CLI
.opencode/INSTALL.md                        # OpenCode (install instructions)
AGENTS.md                                   # Universal baseline (Codex, Antigravity, Devin, Jules, OpenCode, Continue)
CLAUDE.md                                   # This file — contributor notes
skills/seo-for-ai/                          # Single source of truth for the skill
commands/seo-audit.md                       # Slash command, shared
dist/                                       # Fallback artefacts (audit-prompt, per-tool rules for tools without plugin systems)
install.sh                                  # Fallback installer for Windsurf / Aider / Copilot
```

## When editing

- The **canonical skill content** is `skills/seo-for-ai/SKILL.md` plus the
  files in `skills/seo-for-ai/references/`. Everything else (`AGENTS.md`,
  `dist/*.md`, etc.) is **derived** for tools that don't load full skill
  bundles. Update the canonical first, then mirror changes downward.
- When adding a new emerging standard, fact, or recipe: pick exactly one
  reference file in `skills/seo-for-ai/references/` as the home, and link
  from SKILL.md. Don't scatter the same content across multiple files.
- The `/seo-audit` command in `commands/seo-audit.md` should stay
  framework-agnostic; framework-specific advice belongs in SKILL.md so the
  command can stay short.

## When bumping versions

Five files carry a version number, keep them in sync:

- `.claude-plugin/plugin.json` → `version`
- `.claude-plugin/marketplace.json` → `metadata.version` and plugin entry `version`
- `.codex-plugin/plugin.json` → `version`
- `.cursor-plugin/plugin.json` → `version`
- `gemini-extension.json` → `version`

Tag the commit and cut a GitHub release:

```sh
git tag vX.Y.Z && git push --tags
gh release create vX.Y.Z --title "vX.Y.Z — <summary>" --notes "..."
```

## Don't

- Don't add JSON-LD that contradicts visible content in any docs or examples.
  The skill itself flags this; the repo must practice it.
- Don't recommend `noindex` or `Disallow` rules in examples without explicit
  context — the default reader is somebody who wants their site **cited**.
