# Universal AI-visibility audit prompt

Copy-paste into ChatGPT, Codex CLI, Cursor, Windsurf, Aider, Antigravity, or any
agent that lacks a native skill system. Works as a one-shot audit prompt.

Replace `<URL>` (or omit and let it audit the current repo).

---

You are auditing a website for AI-agent visibility (AEO / GEO) and classic
technical SEO. Background: 53% of 2025 web traffic is bots / AI agents. They
fetch with primitive HTTP clients (curl-class), do **not** execute JavaScript,
do **not** wait for hydration, and prefer the fastest static, verifiable source.
GoogleBot caps at ~2 MB initial HTML. Bing is the substrate for most AI agents
except Gemini.

## Target

**URL** (optional): `<URL>`

If no URL, audit the current repository instead — detect framework, locate the
highest-value template, and audit that.

## Procedure

### URL mode

1. Fetch with a bot-class user-agent:
   `curl -sS -A 'Mozilla/5.0 (compatible; GPTBot/1.0; +https://openai.com/gptbot)' -D - -L --max-time 15 '<URL>' -o /tmp/page.html`
2. Also try `/robots.txt`, `/sitemap.xml`, `/llms.txt` at the same origin
   (soft-fail).
3. In the **raw HTML** (no JS), check:
   - `<title>`, single `<h1>`, `<meta name="description">`, `<link rel="canonical">`,
     `hreflang`, `<meta name="robots">`, `<meta charset>`, Open Graph.
   - Presence and validity of `<script type="application/ld+json">` blocks.
     Flag any JSON-LD value that has no visible counterpart.
   - Whether key facts (price, specs, FAQ answers, primary body) are in the
     raw HTML or only appear after JS execution. If body is essentially
     `<div id="root"></div><script>` and nothing more — render-path failure.
   - HTML byte size vs the 2 MB GoogleBot cap.
4. Note response headers: status code, `Content-Type`, `Cache-Control`,
   `X-Robots-Tag`, redirect chain, and CDN/bot-management headers
   (`cf-ray`, `cf-mitigated`, `server`). A `cf-mitigated: challenge` on a
   GPTBot user-agent means Cloudflare is blocking AI bots — robots.txt is
   irrelevant when the request never reaches origin.

### Codebase mode

1. Detect framework via `package.json` / `next.config.*` / `nuxt.config.*` /
   `astro.config.*` / `vite.config.*` / `remix.config.*` etc.
2. Note SSG vs SSR vs CSR per route where determinable.
3. Locate `robots.txt` generator, `sitemap.xml` generator, `<head>` template,
   JSON-LD helpers, pre-render config.
4. Audit the highest-value template first (home, primary landing, product /
   category page). Most risk is template-level, not page-level.

## Checks (6 tiers — stop and fix at first failing tier)

1. **Discoverability & access.** `robots.txt` exists, references sitemap,
   doesn't block AI agents you want citations from. No Cloudflare AI-bot
   blocking. No stale `noindex` from staging.
2. **Render path.** With JS disabled, title + h1 + body + prices + FAQ
   answers all present. Navigation uses `<a href>`. Initial HTML ≤ 2 MB.
3. **Semantic & metadata.** Semantic HTML5 landmarks. Canonical, hreflang,
   Open Graph, per-page dateModified.
4. **Structured data.** JSON-LD for Organization, WebSite+SearchAction,
   Product / Article / FAQPage / HowTo / BreadcrumbList where applicable.
   Validates clean at <https://search.google.com/test/rich-results>.
   Every value matches visible content.
5. **Content shape.** FAQ visible by default with FAQPage JSON-LD. Comparison
   tables use real `<table>`. Steps in `<ol>` or HowTo. Outlinks to verifiable
   first sources (TrustPilot, maps, official docs, vendor pages, author
   profiles via `sameAs`).
6. **Bot policy & measurement.** Bing Webmaster Tools connected. Logs
   segmented by bot user-agent. IndexNow configured.

## Output format

Emit a punch list grouped by severity. For each item include the finding,
evidence (header, HTML line, or file:line), and a concrete fix.

```
## seo-for-ai audit — <target>

### Blocker (bot can't read primary content)
- [finding] — evidence: … — fix: …

### High (will materially hurt citation rate)
- …

### Medium (best-practice gap)
- …

### Watch (emerging standards, not yet load-bearing)
- …

### What's already correct
- …
```

If a section has nothing, write "none found" — don't pad.

## Hard rules

- Do not invent JSON-LD that disagrees with visible content. If visible price
  is 149€ but markup is 99€, that's a **Blocker**, not something you "fix" by
  rewriting one to match the other.
- Do not recommend `noindex` / `Disallow` unless the user explicitly asked to
  *block* AI agents.
- Don't propose changes that alter primary content delivered to bots vs humans.
  Equivalence is the cloaking guardrail.
- If the URL can't be reached (timeout, 403, 5xx), report that as the top
  Blocker and stop. Don't speculate about page content.

## Reference (open in a new tab if you need a deep dive)

- Full skill: <https://github.com/akimovpro/seo-for-ai>
- JSON-LD templates: <https://github.com/akimovpro/seo-for-ai/blob/main/skills/seo-for-ai/references/structured-data.md>
- Bot policy recipes: <https://github.com/akimovpro/seo-for-ai/blob/main/skills/seo-for-ai/references/bot-policy.md>
- Full checklist: <https://github.com/akimovpro/seo-for-ai/blob/main/skills/seo-for-ai/references/checklist.md>

Begin.
