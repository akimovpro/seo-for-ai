---
trigger: glob
description: SEO/AEO/GEO rules for HTML, JSON-LD, robots.txt, and sitemap generation.
globs: "**/*.{tsx,jsx,ts,js,html,vue,svelte,astro,mdx,md},**/robots.txt,**/sitemap*"
---

# SEO for AI agents — Windsurf rules

(Drop into `.windsurf/rules/seo-for-ai.md`, or paste into `.windsurfrules`.)

## Operating principles

1. AI agents don't execute JavaScript. Server-render or pre-render anything
   load-bearing.
2. Static > dynamic. SSG and plain SSR beat SSR-with-hydration.
3. Initial HTML ≤ 2 MB (GoogleBot cap).
4. Bing is the AI substrate. Always connect Bing Webmaster Tools.
5. Cite to be cited — outlink claims to first sources, link reviews to author
   profiles via `sameAs`.
6. Bot HTML must equal user HTML (cloaking = full-site demotion).

## When generating HTML

- Semantic HTML5: `<main>`, `<nav>`, `<header>`, `<footer>`, `<article>`,
  `<section>`. One `<h1>`.
- `<a href>` for navigation, never `<div onClick>`.
- `<link rel="canonical">` on every page.
- `hreflang` reciprocal on multilingual sites.
- Open Graph tags.
- JSON-LD for Product / Article / Organization / FAQPage / HowTo /
  BreadcrumbList / LocalBusiness / SoftwareApplication where applicable.
- FAQ sections visible in HTML on page load (not click-to-render-only).
- Real `<table>` for comparison data, not div-grid.

## When generating robots.txt / sitemap

- robots.txt allows `Googlebot`, `Bingbot`, `OAI-SearchBot`, `ChatGPT-User`,
  `PerplexityBot`, `Perplexity-User`, `Claude-Web`, `Claude-User`,
  `Applebot`. References sitemap.
- sitemap.xml `<lastmod>` is per-URL real edit time, never the build
  timestamp.

## Anti-patterns

- CSR-only routes for content pages.
- Hidden FAQ answers.
- Mass AI-generated multilingual content.
- JSON-LD that contradicts visible content.
- Leftover staging `noindex`.

## Reference

Full skill: <https://github.com/akimovpro/seo-for-ai>
Audit prompt: <https://github.com/akimovpro/seo-for-ai/blob/main/dist/audit-prompt.md>
