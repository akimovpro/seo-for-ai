# Changelog

## [1.2.1] — 2026-05-11

### Fixed
- `install.sh` no longer crashes with `BASH_SOURCE[0]: unbound variable` when
  run via `curl ... | bash`. Dropped `set -u` (BASH_SOURCE is unset under a
  curl pipe).
- `install.sh` detection logic was buggy due to `&&`/`||` precedence in
  shell — Copilot was triggering off the `gh` binary alone, and Codex /
  Antigravity weren't probing for installed apps. Rewrote each detector as
  an explicit `if`.
- AGENTS.md is now **always** written in the current directory regardless of
  what's detected. It's the cross-tool baseline (Codex CLI, Antigravity,
  OpenCode, Devin, Jules, Continue all read it); skipping it when no markers
  were found made the installer feel like it "didn't find" Codex.
- Removed the speculative `.antigravity/rules/` write — Antigravity reads
  `AGENTS.md` at repo root, which is already covered.
- Better detection: Codex by `command -v codex` or `~/.codex/`;
  Antigravity by `/Applications/Antigravity.app` or `~/.antigravity/` or
  `~/Library/Application Support/Antigravity/`; Cursor / Windsurf likewise.

### Changed
- Installer header now prints which tools were detected and where each tool's
  file will land, so the user can verify before / after.

## [1.2.0] — 2026-05-11

### Added — works in every coding agent, not just Claude Code
- `AGENTS.md` at repo root — the cross-tool standard. Picked up by Codex CLI,
  OpenCode, Devin, Jules, Antigravity, Continue, and via `@AGENTS.md` in Cursor.
- `dist/cursor/seo-for-ai.mdc` — Cursor MDC rule file (glob-scoped to HTML /
  JSX / Astro / Vue / Svelte / sitemap / robots files).
- `dist/windsurf/seo-for-ai.md` — Windsurf rules file.
- `dist/copilot/copilot-instructions.md` — `.github/copilot-instructions.md`
  content for GitHub Copilot.
- `dist/audit-prompt.md` — universal copy-paste audit prompt for tools without
  a native skill system (ChatGPT web, etc.).
- `install.sh` — one-liner installer with auto-detection, `--tool` selector,
  `--global` scope, `--dry-run`, safe-by-default (never overwrites).

### Changed
- README install section is now a per-tool matrix covering Claude Code,
  Codex CLI, Antigravity, Cursor, Windsurf, Copilot, Aider, OpenCode,
  Devin, Jules, Continue.

## [1.1.0] — 2026-05-11

### Added
- `/seo-audit [url]` slash command — deterministic entry point.
  - URL mode: fetches with `GPTBot` user-agent, checks raw HTML, robots.txt,
    sitemap.xml, llms.txt, JSON-LD validity, and emits a severity-grouped
    punch list.
  - Codebase mode (no argument): detects framework, audits highest-value
    template, proposes framework-aware fixes.
  - Targeted template mode (file argument).
- README sample of expected output shape.

### Notes
- Skill triggers from natural language ("audit my site for AI visibility",
  etc.) continue to work unchanged.

## [1.0.0] — 2026-05-08

### Initial release
- `seo-for-ai` skill packaged as a Claude Code plugin.
- `SKILL.md` — operating principles, 6-step audit workflow, anti-patterns,
  emerging standards.
- `references/structured-data.md` — JSON-LD templates.
- `references/bot-policy.md` — robots.txt recipes, AI user-agent reference,
  Cloudflare / WAF rules, llms.txt.
- `references/checklist.md` — 10-section flat audit checklist.
