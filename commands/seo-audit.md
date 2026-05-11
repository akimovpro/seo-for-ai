---
description: Run a focused AI-visibility (AEO/GEO) audit on a URL or current codebase. Optional first argument is a URL.
argument-hint: "[url]"
allowed-tools: Read, Glob, Grep, Bash, WebFetch
---

You are running an AI-visibility audit using the **seo-for-ai** skill.

## Mode selection

- If `$1` looks like a URL (starts with `http://` or `https://`) → **URL audit mode**.
- If `$1` is empty → **Codebase audit mode**: audit the current project.
- If `$1` is a file/glob → treat as targeted template audit.

Acknowledge the chosen mode in one line, then proceed silently.

## URL audit mode

1. Fetch the URL with a bot-class user-agent to see what an AI agent actually sees:
   - `curl -sS -A 'Mozilla/5.0 (compatible; GPTBot/1.0; +https://openai.com/gptbot)' -D - -L --max-time 15 "$1" -o /tmp/seo-audit-body.html`
   - Note the final status, `Content-Type`, `Content-Length`, `Cache-Control`, `X-Robots-Tag`, any CDN/bot-management headers (`cf-ray`, `cf-mitigated`, `server`), and the redirect chain.
2. Also fetch `/robots.txt`, `/sitemap.xml`, and `/llms.txt` at the same origin (one call each, soft-fail).
3. In `/tmp/seo-audit-body.html` check the **raw HTML** (no JS):
   - `<title>`, single `<h1>`, `<meta name="description">`, `<link rel="canonical">`, `hreflang`, `<meta name="robots">`, `<meta charset>`, Open Graph tags.
   - Presence and count of `<script type="application/ld+json">` blocks. If present, extract and validate JSON shape; flag any value that has no visible counterpart you can find with `grep` in the same HTML.
   - Whether key facts (price, specs, FAQ answers, primary body text) are present in the raw HTML or only loaded via JS — if the body looks like `<div id="root"></div><script src="...">` and not much else, that's a render-path failure.
   - HTML byte size vs the 2 MB GoogleBot cap.
4. Run the 6-step audit from `references/SKILL.md` against what you observed. Use the JSON-LD reference in `references/structured-data.md` and the policy reference in `references/bot-policy.md` for fixes.

## Codebase audit mode

1. Detect framework: check `package.json`, `next.config.*`, `nuxt.config.*`, `astro.config.*`, `gatsby-config.*`, `vite.config.*`, `remix.config.*`, `svelte.config.*`. Note SSG vs SSR vs CSR per route where possible.
2. Locate: `robots.txt` generator, `sitemap.xml` generator, `<head>` template, JSON-LD helpers, any pre-render config.
3. Identify the **highest-value template** (home, primary landing, product/category page) and audit that first — most risk is template-level, not page-level.
4. Walk the same 6-step audit, but propose fixes in terms of the detected framework (e.g. `app/robots.ts` for Next.js App Router, `next-sitemap` config, Astro `getStaticPaths` lastmod, `nuxt.config.ts` head defaults).

## Output format

Always end with a punch list, grouped by severity. For each item include:
- the **finding** in one sentence,
- the **evidence** (header value / line of HTML / file:line),
- the **fix** (concrete: the exact tag, header, JSON-LD snippet, or file change).

Use this skeleton:

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

If everything looks healthy in a section, write "none found" — don't pad.

## Hard rules

- Do not invent JSON-LD that disagrees with visible content. If the visible text says price 149€ but the markup says 99€, that's a **Blocker** finding, not something you "correct" by rewriting one to match the other.
- Do not recommend `noindex` / Disallow rules unless the user asked to *block* AI agents.
- Don't propose changes that would alter primary content delivered to bots vs humans. Equivalence is the cloaking guardrail.
- If you can't reach the URL (timeout, 403, 5xx), report that as the top Blocker and stop — don't speculate about the page content.

Begin.
