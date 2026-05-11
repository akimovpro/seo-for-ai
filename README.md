# seo-for-ai

> Multi-agent plugin: audit & optimize websites for AI-agent visibility (AEO / GEO) alongside classic SEO. Works in Claude Code, Codex CLI, Cursor, Gemini CLI, OpenCode, Factory Droid, Antigravity, Aider, Windsurf, GitHub Copilot.

53% of 2025 web traffic is bots and AI agents (ChatGPT, Claude, Perplexity, Gemini, Copilot). They fetch with primitive HTTP clients (curl-class), don't execute JavaScript, and don't wait for hydration. Optimizing for them is mostly **going back to basics**: server-rendered HTML, semantic markup, structured data, fast bytes, clean bot policy.

This repo packages that playbook as a portable agent skill — install it in whatever agent you use, and asking "audit my site for AI visibility" or "review my JSON-LD" gets a structured punch-list with concrete fixes.

## Install

### The easiest way — let your agent do it

Paste this into Claude Code, Codex CLI, Cursor, Gemini CLI, OpenCode, Aider,
Antigravity, or any AI coding agent with filesystem access:

```
Install the seo-for-ai skill for me: https://github.com/akimovpro/seo-for-ai
```

The agent figures out where its skills directory is and clones the repo
there. Works everywhere.

### Native plugin marketplaces (preferred — gives you `update`)

| Agent | Command |
|---|---|
| Claude Code | `/plugin marketplace add akimovpro/seo-for-ai` → `/plugin install seo-for-ai@seo-for-ai` |
| Codex CLI | `/plugins` → seo-for-ai |
| Cursor | `/add-plugin akimovpro/seo-for-ai` |
| Gemini CLI | `gemini extensions install https://github.com/akimovpro/seo-for-ai` |
| Factory Droid | `droid plugin install seo-for-ai@seo-for-ai` |
| OpenCode | edit `opencode.json` plugin array — see [.opencode/INSTALL.md](./.opencode/INSTALL.md) |

### Fallback — shell installer

For Antigravity, Windsurf, GitHub Copilot, Aider (no plugin marketplaces yet):

```sh
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash
```

Auto-detects what's installed, writes the right rule file in the right place,
never overwrites. Add `--dry-run`, `--all`, or `--tool <name>`.

### ChatGPT web / any chat without filesystem access

Copy-paste [dist/audit-prompt.md](./dist/audit-prompt.md) into the conversation.

> **Full install matrix with version pinning, uninstall, troubleshooting and direct git-clone paths:** [INSTALL.md](./INSTALL.md).

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

Each plugin marketplace has its own `update` command — see [INSTALL.md](./INSTALL.md#updating). If you cloned directly via the agent-assisted prompt, `cd <skill-dir> && git pull`.

## Background

Built from the talk **"SEO и AI: оптимизация сайтов для поисковых агентов"** by Igor Akimov (May 2025) — slides + Q&A condensed into actionable agent-ready guidance.

Follow the Telegram channel for ongoing updates: [@SEO4AI](https://t.me/SEO4AI).

## Contributing

See [CLAUDE.md](./CLAUDE.md) for repo conventions if you're working on this with an AI agent. The canonical skill source is `skills/seo-for-ai/`; the rest is derived.

## License

MIT — see [LICENSE](./LICENSE).
