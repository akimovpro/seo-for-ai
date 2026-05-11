# Bot Policy: robots.txt, headers, CDN/WAF

A working bot policy distinguishes four purposes and applies different rules to
each — search indexing, AI search/answer, AI training, and user-triggered fetch.

Apply at three layers (in increasing strictness):
1. `robots.txt` — voluntary, but every well-behaved bot reads it.
2. `<meta name="robots">` and `X-Robots-Tag` HTTP header — page-level overrides.
3. CDN / WAF rules (Cloudflare, AWS WAF Bot Control, Akamai) — enforced.

---

## User-agent reference (current as of 2026-Q1)

| User-agent | Operator | Purpose | Notes |
|---|---|---|---|
| `Googlebot` | Google | Search index | Renders JS. 2 MB byte cap. |
| `GoogleOther` | Google | Misc product crawls | |
| `Google-Extended` | Google | Gemini / Vertex AI training | Independent of search. Block to opt out of training. |
| `Bingbot` | Microsoft | Bing search index, AI substrate | Most AI agents read what Bing indexed. |
| `OAI-SearchBot` | OpenAI | ChatGPT search results | Allow if you want ChatGPT citations. |
| `ChatGPT-User` | OpenAI | User-triggered fetch (e.g. user pastes URL) | User explicitly asked → allow. |
| `GPTBot` | OpenAI | OpenAI training | Block to opt out of training. |
| `ClaudeBot` | Anthropic | Anthropic training/index | |
| `Claude-Web` | Anthropic | User-triggered fetch via Claude | |
| `Claude-User` | Anthropic | User-triggered (newer name) | |
| `PerplexityBot` | Perplexity | Answer index | Allow for Perplexity citations. |
| `Perplexity-User` | Perplexity | User-triggered fetch | |
| `Applebot` | Apple | Search / Siri | |
| `Applebot-Extended` | Apple | Apple Intelligence training | |
| `CCBot` | Common Crawl | Open dataset → training | |
| `Meta-ExternalAgent` | Meta | LLaMA training | |
| `Meta-ExternalFetcher` | Meta | User-triggered | |
| `Amazonbot` | Amazon | Alexa / search | |
| `YandexBot` | Yandex | Search | |
| `Bytespider` | ByteDance | TikTok / Doubao training | Aggressive; consider rate-limit or block. |
| `DuckDuckBot` | DuckDuckGo | Search | |
| `Cohere-AI` | Cohere | Training | |
| `Diffbot` | Diffbot | Commercial dataset | |
| `MJ12bot` | Majestic | Backlink crawl | |
| `AhrefsBot` | Ahrefs | Backlink crawl | |
| `SemrushBot` | Semrush | SEO crawl | |

---

## robots.txt — recipes

### Recipe A — public site, want all citations, opt out of training

```
# Allow search and AI answer engines
User-agent: Googlebot
Allow: /

User-agent: Bingbot
Allow: /

User-agent: OAI-SearchBot
Allow: /

User-agent: ChatGPT-User
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: Perplexity-User
Allow: /

User-agent: Claude-Web
Allow: /

User-agent: Claude-User
Allow: /

User-agent: Applebot
Allow: /

# Opt out of training
User-agent: GPTBot
Disallow: /

User-agent: Google-Extended
Disallow: /

User-agent: ClaudeBot
Disallow: /

User-agent: CCBot
Disallow: /

User-agent: Applebot-Extended
Disallow: /

User-agent: Meta-ExternalAgent
Disallow: /

User-agent: Bytespider
Disallow: /

User-agent: Cohere-AI
Disallow: /

# Default — anything not listed
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/internal/
Disallow: /*?utm_

Sitemap: https://example.com/sitemap.xml
```

### Recipe B — public site, want everything (citations AND training contributions)

```
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/internal/

Sitemap: https://example.com/sitemap.xml
```

### Recipe C — block all AI, allow search only

```
User-agent: GPTBot
Disallow: /
User-agent: OAI-SearchBot
Disallow: /
User-agent: ChatGPT-User
Disallow: /
User-agent: ClaudeBot
Disallow: /
User-agent: Claude-Web
Disallow: /
User-agent: Claude-User
Disallow: /
User-agent: PerplexityBot
Disallow: /
User-agent: Perplexity-User
Disallow: /
User-agent: Google-Extended
Disallow: /
User-agent: Applebot-Extended
Disallow: /
User-agent: CCBot
Disallow: /
User-agent: Meta-ExternalAgent
Disallow: /
User-agent: Meta-ExternalFetcher
Disallow: /
User-agent: Bytespider
Disallow: /

User-agent: Googlebot
Allow: /
User-agent: Bingbot
Allow: /
User-agent: YandexBot
Allow: /
User-agent: Applebot
Allow: /

User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

### Recipe D — staging / pre-production

```
User-agent: *
Disallow: /
```

Plus add `<meta name="robots" content="noindex, nofollow">` and an
`X-Robots-Tag: noindex, nofollow` header at the CDN. **Belt-and-suspenders** —
a single layer is one git revert away from leaking.

---

## Page-level overrides

```html
<!-- Block this specific page -->
<meta name="robots" content="noindex, nofollow">

<!-- Allow indexing but no snippet -->
<meta name="robots" content="index, follow, nosnippet">

<!-- AI-specific (Google) -->
<meta name="robots" content="index, follow, max-image-preview:large">

<!-- Opt out of Google AI Overviews specifically (note: also reduces other rich features) -->
<meta name="googlebot" content="nosnippet">
```

HTTP header (works for non-HTML resources too):

```
X-Robots-Tag: noindex
X-Robots-Tag: googlebot: nosnippet
X-Robots-Tag: GPTBot: noindex
```

---

## Cloudflare — the big gotcha

If the site is behind Cloudflare and was added to Cloudflare in the last ~year,
the **"Block AI scrapers and crawlers"** managed rule is enabled by default for
new sites. This blocks `GPTBot`, `ClaudeBot`, `PerplexityBot`, `CCBot`, etc. at
the edge — your `robots.txt` says "Allow" but the bot gets a 403 before it ever
sees the file.

**Check:** Cloudflare Dashboard → site → *Security* → *Bots* → *Configure Super
Bot Fight Mode* / *AI Crawl Control*. Decision is per site owner — but if the
goal is AI citations, this must be off (or set to allow specific agents).

For finer control, write a Cloudflare WAF rule:

```
(http.user_agent contains "GPTBot")
or (http.user_agent contains "ClaudeBot")
or (http.user_agent contains "PerplexityBot")
```
→ Action: **Allow** (overrides managed rules).

For training-only opt-out:
```
(http.user_agent contains "GPTBot")
or (http.user_agent contains "Google-Extended")
or (http.user_agent contains "CCBot")
or (http.user_agent contains "ClaudeBot")
```
→ Action: **Block**.

---

## AWS WAF / CloudFront

Use a Bot Control managed rule group with bot category filters:
- `category:search_engine` → Count or Allow.
- `category:scraping_framework`, `category:http_library` → Block or rate-limit.

For specific AI agents not yet in the managed list, write a custom rule on
`User-Agent` header substring.

---

## llms.txt (root-level, separate from robots.txt)

`llms.txt` is **not** a policy file — it's a curated content map. Place at
`/llms.txt` and link to clean Markdown versions of your most important pages.

Minimal example:

```markdown
# Acme Inc.

> Acme builds widgets for distributed teams.

## Docs

- [Getting Started](https://acme.com/docs/start.md)
- [API Reference](https://acme.com/docs/api.md)
- [CLI](https://acme.com/docs/cli.md)

## Optional

- [Changelog](https://acme.com/changelog.md)
- [Status](https://acme.com/status.md)
```

`/llms-full.txt` is the long-form variant — concatenate all important pages into
a single Markdown file.

Spec: <https://llmstxt.org/>

---

## IP-range verification (defense against UA spoofing)

Don't trust the User-Agent header alone — anyone can claim to be GPTBot. Verify
via published IP ranges and reverse DNS:

- Google: <https://developers.google.com/search/apis/ipranges/googlebot.json>
- OpenAI: <https://openai.com/gptbot.json>, <https://openai.com/searchbot.json>,
  <https://openai.com/chatgpt-user.json>
- Anthropic: <https://anthropic.com/claudebot.json> (publishes ranges)
- Perplexity: <https://perplexity.ai/perplexitybot.json>
- Microsoft Bing: reverse-DNS to `*.search.msn.com`

For high-traffic / abuse-prone sites, gate "AI bot" allowlist actions on IP
verification, not UA string.

---

## What to monitor in logs

Segment by bot user-agent class. Watch for:
- Spike in `403` or `429` for AI bots (you broke their access).
- Spike in `5xx` (your origin can't keep up).
- Redirect loops on canonical URLs.
- Empty / sub-1KB HTML responses to bot UAs (likely your CSR didn't pre-render).
- Bot crawling the same URL hundreds of times/day (rate-limit, or check sitemap
  freshness signals).

Build a weekly dashboard with: bot group × URL template × status × TTFB ×
bytes × cache hit ratio × downstream conversion (where possible).
