# seo-for-ai

> Multi-agent plugin: audit & optimize websites for AI-agent visibility (AEO / GEO) alongside classic SEO. Works in Claude Code, Codex CLI, Cursor, Gemini CLI, OpenCode, Factory Droid, Antigravity, Aider, Windsurf, GitHub Copilot.

53% of 2025 web traffic is bots and AI agents (ChatGPT, Claude, Perplexity, Gemini, Copilot). They fetch with primitive HTTP clients (curl-class), don't execute JavaScript, and don't wait for hydration. Optimizing for them is mostly **going back to basics**: server-rendered HTML, semantic markup, structured data, fast bytes, clean bot policy.

This repo packages that playbook as a portable agent skill — install it in whatever agent you use, and asking "audit my site for AI visibility" or "review my JSON-LD" gets a structured punch-list with concrete fixes.

## Install

Pick your agent. Native plugin systems first, fallback installer at the bottom for tools that don't have one yet.

### Claude Code

```
/plugin marketplace add akimovpro/seo-for-ai
/plugin install seo-for-ai@seo-for-ai
```

Includes the `/seo-audit` slash command.

### Codex CLI

```
/plugins
```

Then search for **seo-for-ai** and install. (Or add via marketplace URL: `https://github.com/akimovpro/seo-for-ai`.)

### Cursor

```
/add-plugin akimovpro/seo-for-ai
```

### Gemini CLI

```
gemini extensions install https://github.com/akimovpro/seo-for-ai
```

### Factory Droid

```
droid plugin marketplace add https://github.com/akimovpro/seo-for-ai
droid plugin install seo-for-ai@seo-for-ai
```

### OpenCode

Add to `~/.config/opencode/opencode.json` (or project-level):

```json
{
  "plugin": ["seo-for-ai@git+https://github.com/akimovpro/seo-for-ai.git"]
}
```

See [.opencode/INSTALL.md](./.opencode/INSTALL.md) for pinning, troubleshooting.

### Antigravity (Google)

Antigravity reads `AGENTS.md` from the repo root. Run the fallback installer below — it drops `AGENTS.md` in the current directory.

### Windsurf, GitHub Copilot, Aider — fallback installer

These don't have a plugin marketplace today. Use the one-liner installer; it
auto-detects which agents you have, writes the right rule file in the right
place, and never overwrites an existing file.

```sh
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash

# preview first:
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --dry-run

# force every supported format:
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --all

# also write user-global rules (~/.codex/AGENTS.md, ~/.cursor/rules/):
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --global
```

### ChatGPT web / any chat without a skill system

Copy-paste the prompt from [dist/audit-prompt.md](./dist/audit-prompt.md) into the conversation, optionally substituting `<URL>` with the page you want audited.

## Install matrix at a glance

| Agent | Install command | What lands |
|---|---|---|
| Claude Code | `/plugin install seo-for-ai@seo-for-ai` | full skill + `/seo-audit` |
| Codex CLI | `/plugins` → seo-for-ai | full skill |
| Cursor | `/add-plugin akimovpro/seo-for-ai` | full skill + commands |
| Gemini CLI | `gemini extensions install <repo url>` | full skill via `GEMINI.md` |
| OpenCode | edit `opencode.json` plugin array | full skill |
| Factory Droid | `droid plugin marketplace add` | full skill |
| Antigravity | fallback installer → `AGENTS.md` | universal baseline |
| Windsurf | fallback installer → `.windsurf/rules/` | rules |
| GitHub Copilot | fallback installer → `.github/copilot-instructions.md` | rules |
| Aider | fallback installer → `CONVENTIONS.md` | rules + use `--read` |
| ChatGPT / web | copy-paste [dist/audit-prompt.md](./dist/audit-prompt.md) | one-shot |

## Usage

Two entry points:

### A. Slash command (Claude Code only)

```
/seo-audit https://example.com           # URL audit
/seo-audit                                # audit current codebase
/seo-audit app/(marketing)/pricing/page.tsx   # template audit
```

### B. Natural language (every agent)

- "Audit https://example.com for AI visibility."
- "Review my JSON-LD on the pricing page."
- "Why isn't ChatGPT citing our docs?"
- "Set up llms.txt for this SDK."
- "Check our robots.txt — Cloudflare might be blocking AI bots."
- "Make this FAQ extractable by AI."

The skill auto-activates on any of those triggers.

## What the output looks like

```
> /seo-audit https://example.com

[URL audit mode] Fetching with GPTBot user-agent…

## seo-for-ai audit — https://example.com

### Blocker (bot can't read primary content)
- Page is CSR-only — raw HTML is `<div id="root"></div>` plus 1.2 MB of JS;
  no title, no h1, no body copy without JS execution.
  evidence: `curl -A GPTBot` returns 4 KB HTML, 0 text nodes outside <script>.
  fix: enable SSR or pre-rendering (Next.js App Router → `export const dynamic =
  'force-static'` for marketing routes; or add prerender.io in front).

### High (will materially hurt citation rate)
- Cloudflare "Block AI scrapers" is ON — `cf-mitigated: challenge` returned
  for GPTBot UA. Robots.txt is irrelevant when the request never reaches origin.
  evidence: response header `cf-mitigated: challenge`, status 403.
  fix: Cloudflare → Security → Bots → AI Crawl Control → Allow.
- No `<link rel="canonical">` — duplicate-content risk on trailing-slash variants.
  fix: add `<link rel="canonical" href="https://example.com/...">` per route.

### Medium (best-practice gap)
- sitemap.xml has identical `<lastmod>` (build timestamp) on all 1,847 URLs.
  fix: source `lastmod` from CMS / git per route.
- No FAQPage JSON-LD on the pricing page; FAQ section exists but only renders
  on click — bots see the questions, not the answers.

### Watch (emerging standards)
- No /llms.txt — site looks developer-facing (SDK + docs), this would help.
- No `Accept: text/markdown` content negotiation on /docs/*.

### What's already correct
- Open Graph tags present and accurate.
- robots.txt references sitemap.xml.
- hreflang correct on /ru/ and /en/ variants.
```

(Sample shape — your output will differ.)

## What's inside

- **`skills/seo-for-ai/SKILL.md`** — 8 operating principles, 6-step audit workflow, anti-patterns, emerging standards roadmap.
- **`skills/seo-for-ai/references/structured-data.md`** — JSON-LD templates: Organization, WebSite + SearchAction, Product, FAQPage, HowTo, Article, BreadcrumbList, LocalBusiness, Review, SoftwareApplication, `@graph` linking.
- **`skills/seo-for-ai/references/bot-policy.md`** — `robots.txt` recipes, full AI user-agent reference, Cloudflare AI-bot gotcha, AWS WAF rules, llms.txt spec, IP-range verification.
- **`skills/seo-for-ai/references/checklist.md`** — 10-section flat audit checklist, usable as a CI gate.
- **`commands/seo-audit.md`** — `/seo-audit` slash command (Claude Code, soon other plugin-marketplace agents).
- **`dist/`** — fallback artefacts: `audit-prompt.md` for copy-paste use, plus tool-specific rule files for Windsurf / Copilot / Cursor.
- **`AGENTS.md`** — universal baseline rules picked up by Codex CLI, Antigravity, OpenCode, Devin, Jules, Continue.

## Updating

| Agent | Update command |
|---|---|
| Claude Code | `/plugin update seo-for-ai` |
| Codex CLI | `/plugins` → seo-for-ai → Update |
| Cursor | `/update-plugin seo-for-ai` |
| Gemini CLI | `gemini extensions update seo-for-ai` |
| Factory Droid | `droid plugin update seo-for-ai` |
| OpenCode | clear cache + restart (see [.opencode/INSTALL.md](./.opencode/INSTALL.md)) |
| Fallback installer | re-run the curl one-liner; existing files are preserved |

## Background

Built from the talk **"SEO и AI: оптимизация сайтов для поисковых агентов"** by Igor Akimov (May 2025) — slides + Q&A condensed into actionable agent-ready guidance.

Follow the Telegram channel for ongoing updates: [@SEO4AI](https://t.me/SEO4AI).

## Contributing

See [CLAUDE.md](./CLAUDE.md) for repo conventions if you're working on this with an AI agent. The canonical skill source is `skills/seo-for-ai/`; the rest is derived.

## License

MIT — see [LICENSE](./LICENSE).
