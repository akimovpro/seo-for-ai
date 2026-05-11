# JSON-LD Templates

Drop these into `<head>` (or just before `</body>`) wrapped in
`<script type="application/ld+json">`. **Critical rule:** every value in JSON-LD
must match what is visibly rendered on the page. Markup that disagrees with the
visible page is treated as deceptive and ignored — or worse, demotes the whole site.

Validate every change at:
- <https://search.google.com/test/rich-results>
- <https://validator.schema.org/>

---

## Organization (site-wide, in `<head>` of every page or just home)

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Example Inc.",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png",
  "sameAs": [
    "https://twitter.com/example",
    "https://www.linkedin.com/company/example",
    "https://github.com/example"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "+1-555-0100",
    "contactType": "customer support",
    "areaServed": "US",
    "availableLanguage": ["English", "Russian"]
  }
}
```

`sameAs` is the most important field for AI trust — it ties the entity to its
verifiable presences elsewhere on the web.

## WebSite + SearchAction (lets agents call your site search)

```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "url": "https://example.com",
  "potentialAction": {
    "@type": "SearchAction",
    "target": {
      "@type": "EntryPoint",
      "urlTemplate": "https://example.com/search?q={search_term_string}"
    },
    "query-input": "required name=search_term_string"
  }
}
```

## Product (e-commerce / SaaS)

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Acme Widget Pro",
  "image": "https://example.com/widget-pro.jpg",
  "description": "...visible description, identical to <p> on the page...",
  "sku": "AWP-001",
  "brand": { "@type": "Brand", "name": "Acme" },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/widgets/pro",
    "priceCurrency": "USD",
    "price": "149.00",
    "availability": "https://schema.org/InStock",
    "priceValidUntil": "2026-12-31"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.7",
    "reviewCount": "382"
  }
}
```

`aggregateRating` must reflect a count visible on the page. `priceValidUntil`
prevents stale price citation.

## FAQPage (single most useful for AI citation)

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does Acme Widget Pro support TypeScript?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Type definitions ship with the npm package; no separate @types install required."
      }
    },
    {
      "@type": "Question",
      "name": "What is the refund policy?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Full refund within 30 days, no questions asked."
      }
    }
  ]
}
```

The `text` of every answer **must** appear in the visible HTML on page load (not
hidden behind a click-to-expand that only renders on interaction).

## HowTo (for tutorials / setup pages)

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "Install Acme Widget Pro on macOS",
  "totalTime": "PT5M",
  "step": [
    {
      "@type": "HowToStep",
      "name": "Install via Homebrew",
      "text": "Run `brew install acme/widget`.",
      "url": "https://example.com/docs/install#brew"
    },
    {
      "@type": "HowToStep",
      "name": "Verify",
      "text": "Run `widget --version` and confirm output starts with 1.",
      "url": "https://example.com/docs/install#verify"
    }
  ]
}
```

## Article / BlogPosting

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "How AI Agents Read Your Website",
  "datePublished": "2026-05-08T10:00:00+03:00",
  "dateModified": "2026-05-08T10:00:00+03:00",
  "author": {
    "@type": "Person",
    "name": "Igor Akimov",
    "url": "https://example.com/team/igor",
    "sameAs": [
      "https://twitter.com/akimov",
      "https://github.com/akimov"
    ]
  },
  "publisher": {
    "@type": "Organization",
    "name": "Example Inc.",
    "logo": {
      "@type": "ImageObject",
      "url": "https://example.com/logo.png"
    }
  },
  "image": "https://example.com/article-hero.jpg",
  "mainEntityOfPage": "https://example.com/blog/how-ai-reads"
}
```

`dateModified` must be the **real** edit time per article — not the build time.

## BreadcrumbList

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com" },
    { "@type": "ListItem", "position": 2, "name": "Docs", "item": "https://example.com/docs" },
    { "@type": "ListItem", "position": 3, "name": "Install", "item": "https://example.com/docs/install" }
  ]
}
```

## LocalBusiness (for businesses with a physical location)

```json
{
  "@context": "https://schema.org",
  "@type": "Restaurant",
  "name": "Acme Café",
  "image": "https://example.com/cafe.jpg",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "ul. Lenina 10",
    "addressLocality": "Moscow",
    "postalCode": "101000",
    "addressCountry": "RU"
  },
  "geo": { "@type": "GeoCoordinates", "latitude": 55.7558, "longitude": 37.6173 },
  "url": "https://example.com",
  "telephone": "+7-495-555-0100",
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Monday","Tuesday","Wednesday","Thursday","Friday"],
      "opens": "09:00",
      "closes": "22:00"
    }
  ],
  "sameAs": [
    "https://maps.app.goo.gl/...",
    "https://www.tripadvisor.com/..."
  ]
}
```

For local search (Google Maps / Yandex Maps voice/local SEO), the `sameAs` link
to the canonical map listing is what ties everything together.

## Review (always link to author entity)

```json
{
  "@context": "https://schema.org",
  "@type": "Review",
  "itemReviewed": { "@type": "Product", "name": "Acme Widget Pro" },
  "reviewRating": { "@type": "Rating", "ratingValue": 5, "bestRating": 5 },
  "author": {
    "@type": "Person",
    "name": "Jane Doe",
    "sameAs": "https://www.trustpilot.com/users/jane-doe"
  },
  "reviewBody": "Cut our processing time in half.",
  "datePublished": "2026-04-20"
}
```

The `author.sameAs` link to a verifiable external profile (TrustPilot, LinkedIn,
GitHub, Instagram) is what flips a review from "could be AI slop" to "verified
human source" for AI ranking.

## SoftwareApplication (for SaaS / mobile apps)

```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Acme Mobile",
  "applicationCategory": "ProductivityApplication",
  "operatingSystem": "iOS, Android",
  "downloadUrl": [
    "https://apps.apple.com/app/id123456",
    "https://play.google.com/store/apps/details?id=com.acme.mobile"
  ],
  "offers": { "@type": "Offer", "price": "0", "priceCurrency": "USD" }
}
```

This is how an agent answers "is there a mobile app for X" — without `downloadUrl`
+ `sameAs` chain, it has to guess.

---

## Linking entities together

Use `@id` to link entities across blocks rather than duplicate them:

```json
{
  "@context": "https://schema.org",
  "@graph": [
    { "@type": "Organization", "@id": "https://example.com/#org", "name": "Acme" },
    {
      "@type": "Product",
      "name": "Widget",
      "brand": { "@id": "https://example.com/#org" }
    }
  ]
}
```

`@graph` keeps the file flat and lets validators see all entities at once.
