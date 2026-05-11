# SEO/AEO/GEO instructions for GitHub Copilot

Drop into `.github/copilot-instructions.md` (repo-level). Copilot will append
these to every Copilot Chat conversation in this repository.

---

This repo serves HTML to the web. When generating or editing code that affects
public pages, follow these rules.

**Render path.** AI agents and many search crawlers do NOT execute JavaScript.
Anything that must be indexed or cited must appear in the **initial HTML
response**. Prefer SSG / plain SSR over SSR-with-hydration over CSR. Initial
HTML must stay ≤ 2 MB (GoogleBot cap).

**Semantic HTML.** Use `<main>`, `<nav>`, `<header>`, `<footer>`, `<article>`,
`<section>`. Exactly one `<h1>` per page. Use `<a href>` for navigation, never
`<div onClick>`. Use real `<table>` for comparison data. Use `<ol>` for step
sequences.

**Structured data (JSON-LD).** Add `<script type="application/ld+json">` for
any recognizable entity: Product, Article, Organization, FAQPage, HowTo,
BreadcrumbList, LocalBusiness, SoftwareApplication. Every value in JSON-LD
**must** match what is visibly rendered (mismatched = deceptive markup =
demoted).

**FAQ sections.** Must be visible in the rendered HTML on page load — use
`<details open>` or render the accordion expanded with visibility toggled via
class. Mark up with `FAQPage` JSON-LD.

**Canonical and i18n.** Every page has `<link rel="canonical">`. Multilingual
sites have reciprocal `hreflang`. Per-page `dateModified` in JSON-LD and
per-URL real `<lastmod>` in `sitemap.xml` (never the build timestamp).

**robots.txt.** Allow `Googlebot`, `Bingbot`, `OAI-SearchBot`, `ChatGPT-User`,
`PerplexityBot`, `Perplexity-User`, `Claude-Web`, `Claude-User`, `Applebot`
unless told otherwise. Reference `sitemap.xml`. If the site is behind
Cloudflare, the "Block AI scrapers" managed rule is OFF by default for new
sites in the last year — verify it before declaring the policy correct.

**Never do**:
- Add `<meta name="robots" content="noindex">` unless explicitly asked.
- Render primary content only via JavaScript.
- Write JSON-LD values that disagree with visible content.
- Propose mass AI-generated multilingual blog content (demoted as slop since
  spring 2025).
- Use a single build timestamp on every URL in `sitemap.xml`.
- Serve different primary content to bots vs humans (cloaking).

**Connect:**
- Google Search Console.
- Bing Webmaster Tools — its AI Performance dashboard is the only place to
  see real AI citations today.
- IndexNow endpoint (free; Bing, Yandex, most non-Google engines).

**Emerging:** add `/llms.txt` for developer-facing sites (SDK, API, docs,
open-source product). Spec: <https://llmstxt.org/>.

Full reference, JSON-LD templates, robots.txt recipes, audit checklist:
<https://github.com/akimovpro/seo-for-ai>.
