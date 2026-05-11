# Changelog

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
