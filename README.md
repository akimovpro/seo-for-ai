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

```
/plugin marketplace add akimovpro/seo-for-ai
/plugin install seo-for-ai@seo-for-ai
```

Then just ask Claude things like:

- "Audit https://example.com for AI visibility."
- "Review my JSON-LD on the pricing page."
- "Why isn't ChatGPT citing our docs?"
- "Set up llms.txt for this SDK."
- "Check our robots.txt — Cloudflare might be blocking AI bots."
- "Make this FAQ extractable by AI."

The skill auto-activates on any of those triggers.

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
