---
name: seo-for-ai
description: |
  Audit and optimize websites for AI agent visibility (AEO/GEO) alongside classic SEO.
  Use when user asks to audit a page or site for AI agents, check AI-readiness, review
  structured data / JSON-LD, fix bot policy, set up llms.txt, debug why ChatGPT/Claude/
  Perplexity don't cite the site, check Cloudflare bot rules, validate Schema.org markup,
  or implement AI-friendly content patterns (FAQ, comparison tables, steps, proof links).
  Also triggers on: "почему меня не цитирует ChatGPT", "AI-видимость", "оптимизация под
  поисковых агентов", "SEO для AI", "AEO", "GEO".
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - WebFetch
---

# SEO for AI Agents (AEO / GEO)

Audit and optimize sites so AI agents (ChatGPT, Claude, Perplexity, Gemini, Copilot)
and modern search crawlers can fetch, parse, trust, and cite their content.

The classic SEO loop — request → render → index → answer — still applies, but AI
agents collapse it: they fetch via primitive HTTP clients (curl-class), do not execute
JavaScript, do not wait for hydration, and prefer the fastest source of static, verifiable
facts. Optimizing for them is mostly **going back to basics**: server-rendered HTML,
semantic markup, structured data, fast bytes, clean policy.

## When this skill is active

Use this skill in any of these situations:

- "Audit this page/site for AI visibility / AEO / GEO."
- "Why doesn't ChatGPT/Claude/Perplexity cite us?"
- "Review structured data / JSON-LD / Schema.org markup."
- "Make our site agent-ready / agent-friendly."
- "Set up / review llms.txt, robots.txt, sitemap.xml for AI."
- "Cloudflare is blocking AI bots — check our rules."
- "Add an FAQ / comparison / steps section that AI will pick up."
- The user pastes a URL and asks for an SEO/AEO/GEO opinion.

If the request is purely classic on-page SEO with no AI angle, this skill still
applies — the foundations overlap.

---

## Operating principles (read these first)

1. **AI agents don't execute JavaScript.** If a fact appears only after hydration,
   half the agents will miss it. Server-render or pre-render anything load-bearing.
2. **Static beats dynamic.** SSR with hydration ≠ static for bots — the initial HTML
   must already contain the primary content. Plain SSR (no client JS) and SSG win.
3. **First 2 MB matter.** GoogleBot caps page reads at ~2 MB; many AI crawlers cap
   lower. Inline base64 images, gigantic SVGs, and oversized JSON payloads silently
   strip late content.
4. **Bing is the AI substrate.** Most AI agents (except Gemini) pull from Bing.
   Bing Webmaster Tools is the only place you can see citations today.
5. **Quality > quantity.** Mass AI-generated multilingual blog content used to spike
   indexation; since spring 2025 it is detected as slop and demoted.
6. **Cite to be cited.** AI ranks visible, verifiable facts. Link reviews to TrustPilot,
   prices to product pages, claims to first sources.
7. **Bot HTML must equal user HTML.** Differing primary content between bots and
   humans = cloaking signal = full-site demotion. Allowed: a class change to "open"
   an accordion. Not allowed: fully different paragraphs.
8. **Logs are the only ground truth.** AI agents rarely show up in JS-based analytics.
   Server / CDN logs are how you actually see them.

---

## Audit workflow

When asked to audit, follow this order. Stop at the first failing tier and fix
before moving on — later tiers depend on earlier ones.

### Step 1 — Discoverability & access (the bot can reach the page)

- `robots.txt` exists, references `sitemap.xml`, and does **not** block the AI
  user-agents the user wants citing them (`GPTBot`, `OAI-SearchBot`, `ChatGPT-User`,
  `PerplexityBot`, `Perplexity-User`, `ClaudeBot`, `Claude-Web`, `Google-Extended`,
  `Bingbot`, `Applebot-Extended`, `CCBot`, `Meta-ExternalAgent`).
- **Cloudflare check (very common pitfall):** if the site is behind Cloudflare and
  was added in roughly the last year, the default "Block AI scrapers and crawlers"
  toggle may be ON. Confirm under *Cloudflare → Security → Bots → Configure*. Same
  for AWS WAF Bot Control / similar managed rules.
- `X-Robots-Tag` HTTP header is not silently overriding `<meta name="robots">`.
- `sitemap.xml` is reachable, valid, and `<lastmod>` is per-URL accurate (not the
  build timestamp; see Step 5).
- IndexNow endpoint configured (Bing/Yandex/most non-Google engines support it;
  Google does not yet).

### Step 2 — Render path (the bot can read the content)

The architecture ladder, best to worst for agents:

```
Static HTML  →  SSR (no JS dependency)  →  Pre-rendering fallback  →  CSR (last resort)
```

- Open the page with **JavaScript disabled** (DevTools → Settings → Debugger → Disable
  JS, or the *Web Developer* / *Disable JavaScript* extension) and verify:
  - `<title>` and `<h1>` are present.
  - Body copy, prices, specs, FAQ answers, key product facts are present.
  - `<a href>` links point to real URLs (not `<div onClick>`).
- Or just: `curl -A 'Mozilla/5.0 (compatible; GPTBot/1.0)' <url> | less` — what you
  see is what the agent sees.
- If the page is CSR-only (e.g., a React SPA with `<div id="root"></div>` and nothing
  else), recommend SSG (Next.js / Astro / Nuxt static), full SSR, or a pre-renderer
  (Prerender.io, prerendering.info, Rendertron, or framework-native).

### Step 3 — Semantic & structured layer (the bot can understand)

- Semantic HTML5: `<main>`, `<nav>`, `<header>`, `<footer>`, `<article>`, `<section>`,
  proper `<h1>`–`<h6>` hierarchy.
- WAI-ARIA where it adds meaning (landmarks, labels for icon buttons, expanded state
  on accordions). Originally for screen readers; agents now use the same signals.
- Open Graph / Twitter cards for previews & social citations.
- **JSON-LD** for entities and actions — see [references/structured-data.md](references/structured-data.md).
  Validate every change at <https://search.google.com/test/rich-results> and
  <https://validator.schema.org/>.
- `<link rel="canonical">` on every page (handles trailing-slash duplicates etc.).
- `hreflang` correct on multilingual sites.
- Per-page `<meta name="last-modified">` / visible date / `dateModified` in JSON-LD.

### Step 4 — Content shape (the bot wants to cite this)

AI systems extract answers, not paragraphs. Restructure for extractability:

- **FAQ sections.** Visible by default in the rendered HTML — even if the visual
  design uses an accordion, render with the panel expanded and toggle visibility
  with a class. Mark up with `FAQPage` JSON-LD. Target real user questions ("Does
  X support Y?"), not keyword phrases.
- **Comparison tables.** AI answers "X vs Y" queries by extracting tables. Use real
  `<table>`, not CSS-grid divs.
- **Step-by-step instructions.** `HowTo` JSON-LD or numbered `<ol>` with named steps.
- **Verifiable proof.** Outlinks to first sources: TrustPilot for reviews, Google
  Maps for locations, official docs for claims, vendor pages for specs. Reviews
  should link to a verifiable author entity (JSON-LD `Person` with `sameAs`).

### Step 5 — Page weight & timestamps

- Total bytes of the **initial HTML response** ≤ 2 MB (GoogleBot hard limit).
  Watch for: inline base64 images, oversized inline SVG sprites, gigantic inline
  JSON state hydration blobs, every translation embedded for every locale.
- `lastmod` in sitemap and `dateModified` in JSON-LD must reflect **per-page** real
  edit time. **Common SSG bug:** every page in `sitemap.xml` shares the build
  timestamp. Bots see "everything updated" but content is identical → priority drops
  and recrawl frequency is throttled. Fix: source `lastmod` from CMS / git / file
  mtime per route.

### Step 6 — Bot policy matrix

Distinguish four bot purposes and apply different rules to each:

| Purpose | Examples | Default action |
|---|---|---|
| Search indexing | `Googlebot`, `Bingbot`, `YandexBot` | Allow |
| AI search / answer | `OAI-SearchBot`, `PerplexityBot`, `ChatGPT-User` | Allow if you want citations |
| AI training | `GPTBot`, `Google-Extended`, `CCBot`, `ClaudeBot` (training) | Org policy — often block |
| User-triggered fetch | `ChatGPT-User`, `Perplexity-User`, `Claude-Web` | Allow (user explicitly asked) |

Store this matrix in version control. Re-check quarterly. Apply at three layers:
`robots.txt` → `<meta name="robots">` / `X-Robots-Tag` → CDN/WAF rules.

### Step 7 — Measurement

- **Google Search Console** — classic outcomes for Google.
- **Bing Webmaster Tools** — has an *AI Performance* / citations panel. The single
  most useful AI-visibility dashboard available today. Always connect this.
- **Server / CDN logs** — segment by bot user-agent, watch for spikes of `403`,
  `429`, `5xx`, redirect loops, and empty HTML responses to automated traffic.
- For deep crawls: Screaming Frog SEO Spider (free up to 500 URLs; paid for more).
- For ad-hoc page checks: SEO Meta in 1 Click (Chrome extension), prerendering.info
  SEO Audit, isitagentready.com, acceptmarkdown.com.

---

## Anti-patterns (flag these aggressively)

- **CSR-only content.** "It works in the browser" is not enough. The bot doesn't
  run a browser.
- **Hidden FAQ rendered only on click.** If the HTML doesn't contain the answer
  text without JS, the bot won't see it. And if it differs from what the user sees
  after click → cloaking risk.
- **`<a>` replaced with `<div onClick={navigate(...)}>`.** Bots don't follow JS
  click handlers.
- **Mass AI-generated multilingual content.** Detected and demoted since ≈Apr 2025.
- **JSON-LD that disagrees with visible content.** Markup says price 99€, page
  shows 149€ → markup is treated as deceptive and ignored.
- **`<meta name="robots" content="noindex">` left over from staging** in production.
- **`Cache-Control: private` on public pages** behind a CDN — bots get stale or
  empty responses.
- **Single build timestamp on every URL** in `sitemap.xml`.
- **2 MB+ initial HTML.** Late content is silently dropped.
- **Cloudflare default-deny on AI bots** when the site owner wants citations.

---

## Emerging standards to enable proactively

- **`llms.txt`** (root of site, plain text or Markdown) — curated index of clean,
  machine-readable content. Adopted by AI IDEs (Cursor, Claude Code, Codex) and
  doc agents. Especially valuable for SaaS / SDK / API / open-source product sites.
  Format spec: <https://llmstxt.org/>.
- **Markdown content negotiation.** Serve `Accept: text/markdown` requests with
  the Markdown source of the page (with `Vary: Accept`). Falls back to HTML for
  browsers. Test with <https://acceptmarkdown.com/>.
- **NLWeb** (Schema.org / Microsoft) — natural-language endpoints over your structured
  data so agents can query without scraping HTML.
- **Web MCP** — Model Context Protocol for sites; lets agents call your site's
  functionality directly (form fill, search, checkout). Pre-1.0 but worth tracking.
- **Agent payment protocols** (`x402`, ACP, AP2, UCP) — agents transacting on the
  user's behalf. Plan a year ahead for commerce sites.
- **Web Bot Auth + RSL (Robot Support License)** — emerging identity & licensing
  for autonomous bots. Shape your terms of service & access policy now.

---

## When the user gives you a URL

1. `WebFetch` or `curl -A 'Mozilla/5.0 (compatible; GPTBot/1.0)'` the URL.
2. Note response code, content size, presence of title / H1 / body / canonical /
   JSON-LD / OpenGraph in the **raw HTML** (no JS).
3. Run through Steps 1–6 of the audit above.
4. Output findings as a punch-list grouped by severity:
   - **Blocker** (bot can't read the content at all).
   - **High** (will materially hurt citation rate).
   - **Medium** (best-practice gap).
   - **Watch** (pre-emptive for emerging standards).
5. For each finding, give a concrete fix: file/line if it's their codebase, or
   the exact tag/header to add otherwise.

## When the user gives you a codebase

1. Detect the framework (`grep -r "next" package.json` etc.).
2. Locate the rendering boundary: SSG vs SSR vs CSR per route.
3. Find `robots.txt`, `sitemap.xml` generators, `<head>` template, JSON-LD helpers.
4. Run the audit against templates rather than every page — one template usually
   accounts for most of the risk.
5. Propose changes scoped to the framework (e.g., `next-sitemap` config, Astro
   `getStaticPaths` lastmod, `app/robots.ts` for Next.js App Router).

---

## Reference files

- [references/structured-data.md](references/structured-data.md) — JSON-LD templates
  (Product, Organization, FAQPage, HowTo, Article, BreadcrumbList, SearchAction).
- [references/bot-policy.md](references/bot-policy.md) — `robots.txt` recipes,
  user-agent list, CDN/WAF rule examples.
- [references/checklist.md](references/checklist.md) — full audit checklist as
  a flat list, useful as a CI gate.

## External tools (reach for when validating)

- Google Rich Results Test — <https://search.google.com/test/rich-results>
- Schema.org Validator — <https://validator.schema.org/>
- SEO Meta in 1 Click (Chrome) — <https://chromewebstore.google.com/detail/seo-meta-in-1-click/bjogjfinolnhfhkbipphpdlldadpnmhc>
- prerendering.info SEO Audit — <https://prerendering.info/seo-tools/seo-audit>
- isitagentready.com — <https://isitagentready.com/>
- acceptmarkdown.com — <https://acceptmarkdown.com/>
- Screaming Frog SEO Spider — <https://www.screamingfrog.co.uk/seo-spider/>
- Bing Webmaster Tools (the AI citations source of truth) — <https://www.bing.com/webmasters>
- IndexNow — <https://www.indexnow.org/>

## Related skills

- `claude-seo` (AgriciDaniel) — heavier external workflow; good for full-codebase
  audits but eats half the context window. Use it for one-off audit jobs, not as
  always-on guidance.
- `SEO-GEO-AEO Skill` (SNLabat) — lightweight checklist-style skill, the inspiration
  for this one. Compatible.
