# URL Shortener with Analytics

Build a URL shortener with per-link click analytics. No user accounts are required — a visitor's recently created links are tracked through the browser's `localStorage`. Paste a long URL, get a short link, share it, and watch the click data roll in on a per-link dashboard.

## Stack

- **Frontend**: Vite + React + TailwindCSS (3000)
- **Backend**: Django + Sqlite (3001)

## Features

### Link Creation

The home page hosts a form where users submit a long URL. Optionally they may supply:

- A **custom slug** — the path component of the short URL (e.g. `my-launch`). If omitted, a short alphanumeric code is auto-generated.
- A **click limit** — the link deactivates after this many total clicks.
- An **expiry date** — the link deactivates after this date/time.

Both expiry conditions may be set simultaneously; whichever triggers first deactivates the link.

Slugs must be unique across all links. Submitting a slug that already exists must surface a visible error — no redirect, no silent failure.

On success, the short URL is displayed in-place along with a link to the analytics dashboard.

### Short Link Redirect

Visiting `GET /<slug>` on port 3001 resolves the short link. Active links respond with an HTTP 302 redirect to the target URL and record the visit. Links that are expired (click limit reached or past expiry date) or simply don't exist both redirect to the frontend's `/expired` page — the distinction between "expired" and "not found" does not need to be surfaced to the visitor.

### Click Tracking

Each visit to a short link records:
- A timestamp (used for the over-time chart)
- The value of the `Referer` HTTP request header, if present
- The visitor's country, derived from their IP address

For IP geolocation, use any approach you like (e.g. `geoip2` + MaxMind GeoLite2, or a third-party IP API). If a country cannot be determined, store `"Unknown"`.

### Analytics Dashboard

The analytics page for a given slug displays:

- **Total clicks** — a single aggregate number
- **Clicks over time** — a line chart, one data point per calendar day
- **Top referrers** — ranked list of referring domains (or `"Direct"` when no `Referer` header was sent)
- **Geographic breakdown** — list of countries with their respective click counts

### Recent Links

After creating a short link, its slug is saved to `localStorage`. The home page reads these slugs and fetches current details for each, displaying them as cards below the form. Cards show the short URL, the original URL, and the current click count. Clearing `localStorage` resets this list.

## Pages

**`/`** — Home page. Shortener form at the top; recent-links list below.

**`/analytics/:slug`** — Analytics dashboard for the given slug.

**`/expired`** — Shown when a visitor follows a short link that is expired or does not exist.

## UI Requirements

Use these `data-testid` attributes exactly — automated tests depend on them.

### Home page (`/`)

| Attribute | Element |
|-----------|---------|
| `data-testid="url-input"` | Long URL text field |
| `data-testid="custom-slug-input"` | Optional custom slug field |
| `data-testid="max-clicks-input"` | Optional max-clicks numeric field |
| `data-testid="expiry-date-input"` | Optional expiry date/time field |
| `data-testid="shorten-btn"` | Form submit button |
| `data-testid="shorten-error"` | Error message element (duplicate slug, invalid URL, etc.) |
| `data-testid="short-url-result"` | The full short URL shown after successful creation (text content must be the URL itself) |
| `data-testid="analytics-link"` | Anchor/button linking to `/analytics/:slug`, shown alongside the result |
| `data-testid="recent-links-list"` | Wrapper around all recent-link cards |
| `data-testid="recent-link-card"` | Each individual recent link card (multiple) |
| `data-testid="recent-link-short-url"` | Short URL text inside a card |
| `data-testid="recent-link-original-url"` | Original URL text inside a card |
| `data-testid="recent-link-clicks"` | Click count inside a card (numeric text) |
| `data-testid="empty-recent-links"` | Shown when the recent-links list is empty |

### Analytics page (`/analytics/:slug`)

| Attribute | Element |
|-----------|---------|
| `data-testid="analytics-slug"` | Displays the slug or full short URL |
| `data-testid="total-clicks"` | Total click count (numeric text) |
| `data-testid="clicks-chart"` | Line chart container |
| `data-testid="referrers-list"` | Wrapper around all referrer rows |
| `data-testid="referrer-row"` | Each referrer entry (multiple) |
| `data-testid="referrer-name"` | Referring domain or `"Direct"` inside a row |
| `data-testid="referrer-count"` | Click count for that referrer inside a row |
| `data-testid="geo-list"` | Wrapper around all geographic rows |
| `data-testid="geo-row"` | Each country entry (multiple) |
| `data-testid="geo-country"` | Country name inside a row |
| `data-testid="geo-count"` | Click count for that country inside a row |

### Expired page (`/expired`)

| Attribute | Element |
|-----------|---------|
| `data-testid="expired-message"` | Message telling the visitor the link is no longer available |

## Tailwind Requirements

- Install Tailwind via the official Vite plugin (`@tailwindcss/vite`).
- No other CSS frameworks. A single `index.css` may contain only `@import "tailwindcss"` — no custom rules.
- All layout, spacing, color, and typography must use Tailwind utility classes.
