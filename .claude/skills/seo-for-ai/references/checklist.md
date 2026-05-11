# Audit Checklist

A flat checklist suitable as a CI gate or pre-launch review. Pair with
`SKILL.md` for diagnosis and fix patterns.

## 1. Discoverability & access

- [ ] `robots.txt` exists at site root, returns 200.
- [ ] `robots.txt` references `sitemap.xml`.
- [ ] AI agents the site wants citations from are not blocked in `robots.txt`.
- [ ] Cloudflare "Block AI scrapers" is OFF (or specific allow rules in place).
- [ ] No managed WAF rule blocks `GPTBot` / `OAI-SearchBot` / `PerplexityBot` /
      `ClaudeBot` / `Bingbot` unintentionally.
- [ ] No leftover staging `<meta name="robots" content="noindex">` in production.
- [ ] No leftover `X-Robots-Tag: noindex` HTTP header in production.
- [ ] `sitemap.xml` is reachable, well-formed, and lists all public URLs.
- [ ] `<lastmod>` in sitemap is per-URL accurate (NOT the build timestamp).
- [ ] IndexNow endpoint configured (Bing / Yandex / others).

## 2. Render path

- [ ] With JavaScript disabled, `<title>` is present.
- [ ] With JS disabled, `<h1>` is present and matches the visible heading.
- [ ] With JS disabled, primary body content is in the HTML (prices, specs,
      FAQ answers, key facts).
- [ ] All navigation links use `<a href>`, not `<div onClick>`.
- [ ] `curl -A 'Mozilla/5.0 (compatible; GPTBot/1.0)' <url>` returns the same
      primary content as the rendered browser.
- [ ] Initial HTML response is ≤ 2 MB (GoogleBot cap).
- [ ] No more than 500 KB of inline base64 images / SVGs / state blobs in
      initial HTML.
- [ ] TTFB ≤ 800 ms for crawler IP ranges (check via logs).

## 3. Semantic & metadata

- [ ] `<html lang="...">` set correctly.
- [ ] Exactly one `<h1>` per page, matching page intent.
- [ ] `<main>`, `<nav>`, `<header>`, `<footer>` landmarks present.
- [ ] `<title>` ≤ 60 chars, unique per page.
- [ ] `<meta name="description">` present, ≤ 160 chars, unique per page.
- [ ] `<link rel="canonical">` present and accurate (incl. trailing-slash decision).
- [ ] `hreflang` set on multilingual sites and reciprocal between languages.
- [ ] Open Graph: `og:title`, `og:description`, `og:image`, `og:url`, `og:type`.
- [ ] Twitter card meta present (or just rely on OG fallbacks).
- [ ] `<meta charset="utf-8">` first thing in `<head>`.
- [ ] Per-page visible date (article / blog) AND `dateModified` in JSON-LD.

## 4. Structured data (JSON-LD)

- [ ] `Organization` JSON-LD on home / global, with `sameAs` to verified
      external profiles.
- [ ] `WebSite` + `SearchAction` JSON-LD on home (lets agents call site search).
- [ ] Page-type JSON-LD where applicable: `Product`, `Article`, `FAQPage`,
      `HowTo`, `LocalBusiness`, `BreadcrumbList`, `SoftwareApplication`.
- [ ] Validates clean at <https://search.google.com/test/rich-results>.
- [ ] Validates clean at <https://validator.schema.org/>.
- [ ] Every value in JSON-LD also appears in the visible page (no markup-only
      facts).
- [ ] `aggregateRating.reviewCount` matches what's visible on the page.
- [ ] `Offer.price` matches the visible price (and `priceValidUntil` is in
      the future).
- [ ] Reviews link to author entity with `sameAs` to a verifiable external
      profile.

## 5. Content shape

- [ ] FAQ section present where it makes sense (product, pricing, support).
- [ ] FAQ answers visible in HTML on page load (not click-to-expand only).
- [ ] FAQ marked up with `FAQPage` JSON-LD.
- [ ] Comparison table uses real `<table>`, not div-grid.
- [ ] Step-by-step instructions use `<ol>` or `HowTo` JSON-LD.
- [ ] Outlinks to first sources for claims, prices, reviews, specs.
- [ ] No mass AI-generated multilingual blog content (or, if any, it has been
      reviewed and edited by a human).
- [ ] Author byline with link to author entity on long-form content.

## 6. Page weight & performance

- [ ] Initial HTML ≤ 2 MB.
- [ ] No render-blocking 3rd-party scripts in `<head>` (chat widgets,
      analytics — defer / async).
- [ ] Hero image uses modern format (WebP / AVIF) with explicit width/height
      to prevent CLS.
- [ ] Fonts use `font-display: swap`.
- [ ] LCP < 2.5 s on 4G mobile profile.
- [ ] CLS < 0.1.

## 7. Bot policy & monitoring

- [ ] Bot policy matrix documented in repo (`docs/bot-policy.md` or similar).
- [ ] Per-purpose distinction: search / AI search / training / user-triggered.
- [ ] Bing Webmaster Tools account connected; AI Performance dashboard enabled.
- [ ] Google Search Console connected.
- [ ] Server / CDN logs export to a queryable warehouse.
- [ ] Weekly review: bot group × URL template × status × TTFB × bytes ×
      cache hit ratio.
- [ ] Alerts on `403` / `429` / `5xx` spikes for known good bots.
- [ ] Alerts on empty-HTML responses to bot UAs (CSR pre-render broke).

## 8. Emerging standards

- [ ] `llms.txt` published if the site is developer-facing (docs, SDK, API,
      open-source product).
- [ ] `/llms-full.txt` for long-form ingestion if applicable.
- [ ] Markdown content negotiation considered (`Accept: text/markdown` →
      Markdown source). Test at <https://acceptmarkdown.com/>.
- [ ] NLWeb / Web MCP on the roadmap if the site has interactive functionality
      worth exposing to agents.

## 9. Equivalence (cloaking guardrail)

- [ ] Bot-served HTML and human-served HTML have **equivalent primary content**.
- [ ] If pre-rendering, the snapshot is regenerated when content changes
      (not stale).
- [ ] FAQ-section HTML is the same for bots and humans (only visibility
      class differs).
- [ ] Geo-redirected variants are linked via `hreflang`, not silently swapped.

## 10. Sanity checks before declaring done

- [ ] One critical landing page (highest-converting URL) goes through this
      whole list manually.
- [ ] Audit one product / category template, not just the home page.
- [ ] After fixes, recrawl via Screaming Frog or Bing Webmaster Tools URL
      Inspection.
- [ ] Submit changed URLs via IndexNow.
- [ ] Wait 7–14 days, then check Bing Webmaster Tools AI Performance for
      uplift in citations.
