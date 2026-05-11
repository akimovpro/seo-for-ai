# seo-for-ai — operating rules

Apply these whenever you're generating, editing, or reviewing code that ships
HTML to the web (websites, landing pages, docs, marketing pages, e-commerce).
The goal is that AI agents (ChatGPT, Claude, Perplexity, Gemini, Copilot) and
classic search can fetch, parse, trust, and cite the resulting pages.

## 8 operating principles

1. **AI agents don't execute JavaScript.** If a fact appears only after
   hydration, half the agents miss it. Server-render or pre-render anything
   load-bearing.
2. **Static beats dynamic.** SSR with hydration ≠ static for bots — the
   initial HTML must already contain the primary content. SSG and plain SSR win.
3. **First 2 MB matter.** GoogleBot caps page reads at ~2 MB. Inline base64
   images, oversized SVGs, and large JSON state blobs silently strip late content.
4. **Bing is the AI substrate.** Most AI agents (except Gemini) pull from Bing.
   Always set up Bing Webmaster Tools — its *AI Performance* dashboard is the
   only place you see real citations today.
5. **Quality > quantity.** Mass AI-generated multilingual blog content is
   demoted as slop since spring 2025. Don't propose it.
6. **Cite to be cited.** Outlink claims to first sources, reviews to TrustPilot
   or maps, prices to product pages, authors to verifiable profiles via `sameAs`.
7. **Bot HTML must equal user HTML.** Different primary content for bots vs
   humans = cloaking = full-site demotion. Toggling a visibility class to "open"
   an accordion is fine; serving different paragraphs is not.
8. **Logs are the only ground truth.** AI agents rarely appear in JS analytics.
   Read server / CDN logs.

## Hard rules when generating code

- **Use `<a href>` for navigation, never `<div onClick>`.** Bots don't follow
  JS click handlers.
- **Use semantic HTML5:** `<main>`, `<nav>`, `<header>`, `<footer>`, `<article>`,
  `<section>`, proper `<h1>`–`<h6>` hierarchy, exactly one `<h1>` per page.
- **Add JSON-LD on every page that has a recognizable entity** (Product,
  Article, Organization, FAQPage, HowTo, BreadcrumbList, LocalBusiness,
  SoftwareApplication). Every value in JSON-LD must match the visible content.
- **`<link rel="canonical">` on every page** to handle trailing-slash duplicates.
- **`hreflang`** correct & reciprocal on multilingual sites.
- **Per-page `dateModified`** in JSON-LD and per-URL `<lastmod>` in `sitemap.xml`
  — never the build timestamp.
- **FAQ sections must be visible in the rendered HTML on page load.** Use
  `<details open>` or render the accordion expanded by default and toggle
  visibility with a class. Mark up with `FAQPage` JSON-LD.
- **Use real `<table>` for comparison data**, not div-grid.
- **Step-by-step content uses `<ol>` or `HowTo` JSON-LD.**

## Bot policy

- Default `robots.txt`: allow `Googlebot`, `Bingbot`, `OAI-SearchBot`,
  `ChatGPT-User`, `PerplexityBot`, `Perplexity-User`, `Claude-Web`, `Claude-User`,
  `Applebot`. Org policy decides whether to block training agents (`GPTBot`,
  `Google-Extended`, `ClaudeBot`, `CCBot`, `Applebot-Extended`,
  `Meta-ExternalAgent`).
- `sitemap.xml` referenced in `robots.txt`.
- If the site is behind Cloudflare and the goal is AI citations, verify the
  "Block AI scrapers and crawlers" managed rule is OFF (it's on by default for
  new sites added in the last year).
- Configure IndexNow (free; Bing, Yandex, most non-Google engines).

## Anti-patterns to flag

- CSR-only routes for content pages (`<div id="root"></div>` is not a site).
- Hidden FAQ rendered only after JS click.
- Mass AI-generated multilingual content.
- JSON-LD that disagrees with visible content (deceptive markup → ignored).
- `<meta name="robots" content="noindex">` leftover from staging.
- Single build timestamp on every URL in `sitemap.xml`.
- Initial HTML > 2 MB.

## Emerging standards (enable when relevant)

- **`llms.txt`** at site root for developer-facing sites (SDKs, APIs, docs,
  open-source). Spec: <https://llmstxt.org/>.
- **Markdown content negotiation** (`Accept: text/markdown` + `Vary: Accept`)
  for documentation sites.
- **NLWeb / Web MCP** for sites with interactive functionality worth exposing
  to agents (search, forms, checkout).
- **Agent-payment protocols** (`x402`, ACP, AP2, UCP) for commerce — track,
  don't deploy yet.

## When asked to "audit" or "review" a site or page

Use the audit prompt at <https://github.com/akimovpro/seo-for-ai/blob/main/dist/audit-prompt.md>
or, if running Claude Code with this plugin installed, the `/seo-audit` command.

The full reference (operating principles, 6-step workflow, JSON-LD templates,
robots.txt recipes, full checklist) lives at
<https://github.com/akimovpro/seo-for-ai>.
