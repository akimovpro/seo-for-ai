# seo-for-ai

> Claude Code plugin: audit & optimize websites for AI-agent visibility (AEO / GEO) alongside classic SEO.

53% of web traffic in 2025 is bots. AI agents (ChatGPT, Claude, Perplexity, Gemini) fetch sites with primitive HTTP clients — no JavaScript, no waiting for hydration, no rendering. Optimizing for them is mostly **going back to basics**: server-rendered HTML, semantic markup, structured data, fast bytes, clean bot policy.

This skill packages the technical SEO playbook for that world into a single Claude Code skill — so when you ask Claude to "audit my site for AI visibility" or "review my JSON-LD" or "why isn't ChatGPT citing us", it knows what to check and what to fix.

## What's inside

- **Operating principles** — the 8 rules that govern modern AI-aware SEO (static beats dynamic, 2 MB byte cap, Bing is the AI substrate, no cloaking, etc.).
- **6-step audit workflow** — discoverability → render path → semantic layer → content shape → page weight & timestamps → bot policy → measurement.
- **JSON-LD templates** — Organization, WebSite + SearchAction, Product, FAQPage, HowTo, Article, BreadcrumbList, LocalBusiness, Review, SoftwareApplication, plus `@graph` linking patterns.
- **Bot policy recipes** — 4 ready-to-use `robots.txt` patterns, full AI user-agent reference, Cloudflare AI-bot gotcha, AWS WAF rules, IP-range verification.
- **Audit checklist** — 10-section flat checklist usable as a CI gate.
- **Emerging standards** — `llms.txt`, Markdown content negotiation, NLWeb, Web MCP, agent-payment protocols (x402 / ACP / AP2 / UCP), Web Bot Auth / RSL.

## Install

**Claude Code (most complete — includes the `/seo-audit` slash command):**

```
/plugin marketplace add akimovpro/seo-for-ai
/plugin install seo-for-ai@seo-for-ai
```

**Everything else (Codex CLI, Cursor, Windsurf, Copilot, Aider, Antigravity, …):**

```sh
# one-liner installer — auto-detects which agents this repo uses and drops
# the right rules file in the right place. Safe: never overwrites.
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash

# or, target a specific tool:
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --tool cursor

# or, user-global (Codex / Cursor):
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --global

# dry-run first if you want to see what it would do:
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --dry-run
```

### Per-tool install matrix

| Tool | What lands where | One-shot audit |
|---|---|---|
| **Claude Code** | `/plugin install seo-for-ai@seo-for-ai` (skill + `/seo-audit` command) | `/seo-audit <url>` |
| **Codex CLI** | `AGENTS.md` in repo root, or `~/.codex/AGENTS.md` for global | paste [audit-prompt.md](./dist/audit-prompt.md) |
| **Antigravity** (Google) | `AGENTS.md` in repo root | paste [audit-prompt.md](./dist/audit-prompt.md) |
| **Cursor** | `.cursor/rules/seo-for-ai.mdc` | paste [audit-prompt.md](./dist/audit-prompt.md) |
| **Windsurf** | `.windsurf/rules/seo-for-ai.md` | paste [audit-prompt.md](./dist/audit-prompt.md) |
| **GitHub Copilot** | `.github/copilot-instructions.md` | paste [audit-prompt.md](./dist/audit-prompt.md) |
| **Aider** | `CONVENTIONS.md` + `aider --read CONVENTIONS.md` | paste [audit-prompt.md](./dist/audit-prompt.md) |
| **OpenCode / Devin / Jules / Continue** | `AGENTS.md` (most read it) | paste [audit-prompt.md](./dist/audit-prompt.md) |

The cross-tool baseline is `AGENTS.md` — the de-facto standard since ~mid-2025
and read by Codex CLI, OpenCode, Devin, Jules, Aider (via CONVENTIONS), Cursor
(via `@AGENTS.md`), Antigravity, and several others.

## Usage

Two entry points:

### A. Slash command (deterministic)

```
/seo-audit https://example.com           # URL audit
/seo-audit                                # audit current codebase
/seo-audit app/(marketing)/pricing/page.tsx   # template audit
```

### B. Natural language (auto-triggered)

Just ask Claude things like:

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
  fix: Cloudflare → Security → Bots → AI Crawl Control → Allow (or set
  per-bot rules for OAI-SearchBot, PerplexityBot, ClaudeBot).
- No `<link rel="canonical">` — duplicate-content risk on trailing-slash variants.
  evidence: missing from <head>.
  fix: add `<link rel="canonical" href="https://example.com/...">` per route.

### Medium (best-practice gap)
- sitemap.xml has identical `<lastmod>` (build timestamp) on all 1,847 URLs.
  fix: source `lastmod` from CMS / git per route; bots throttle recrawl when
  every URL claims to update on every deploy.
- No FAQPage JSON-LD on the pricing page; FAQ section exists but only renders
  on click — bots see the questions, not the answers.
  fix: render <details open> by default, add FAQPage JSON-LD (see
  references/structured-data.md).

### Watch (emerging standards)
- No /llms.txt — site looks developer-facing (SDK + docs), this would help.
- No `Accept: text/markdown` content negotiation on /docs/*.

### What's already correct
- Open Graph tags present and accurate.
- robots.txt references sitemap.xml.
- hreflang correct on /ru/ and /en/ variants.
```

(That's a real-shape sample — your output will differ by site.)

## Use without the plugin

Clone into `~/.claude/skills/`:

```sh
cd ~/.claude/skills
git clone https://github.com/akimovpro/seo-for-ai.git
```

The skill at `seo-for-ai/.claude/skills/seo-for-ai/` will work either way.

## Background

Built from the talk **"SEO и AI: оптимизация сайтов для поисковых агентов"** by Igor Akimov (May 2025) — slides + Q&A condensed into actionable Claude-ready guidance.

Follow the Telegram channel for ongoing updates: [@SEO4AI](https://t.me/SEO4AI).

## License

MIT — see [LICENSE](./LICENSE).
