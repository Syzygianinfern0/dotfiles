---
name: webread
description: Read a web page that the agent's normal fetch can't get, because the site blocks bots (HTTP 403/429, "Access Denied", "Just a moment...", "verify you are human", a CAPTCHA page, or a suspiciously empty or truncated page), through ~/bin/webread, which escalates from a browser-like HTTP request to a headless anti-detect browser to an archived copy. Use whenever a page fetch fails or comes back as a bot wall during research, e.g. retail product pages (REI, Amazon, Walmart), Reddit, forums, review sites. Not for pages behind a login, for bulk scraping, or for solving CAPTCHAs.
---

# Reading pages that block bots

Many sites block automated fetchers even for ordinary reading. Work down this chain and stop at the first step that
gives you the content you need:

1. **The agent's normal tools.** A web search often answers a fact (a price, a spec, a date) straight from the
   result snippets with no page fetch at all. Then the normal page fetch.
2. **`webread <url>`** when the fetch fails or returns a bot wall (403/429, "Access Denied", "Just a moment...",
   a CAPTCHA, an almost empty page). It prints the page as Markdown, with any structured data (JSON-LD: product
   name, price, stock, rating; article author and dates) first. A one-line status goes to stderr.
3. **The user's own browser**, only on the Mac and only when step 2 exits with code 2 ("blocked at every step").
   Use whatever browser-control tool this agent has (a browser extension or a DevTools MCP attached to the user's
   Chrome), open the page in a new tab, read it, and close the tab. Tell the user first, because it opens tabs in
   their browser with their logged-in sessions; don't click, type or log in anywhere beyond reading the page. If
   the agent has no browser tool, ask the user to paste the page or save it as a file, or find another source.
4. **Another source** for the same information: the publisher, arXiv or the DOI page instead of ResearchGate or
   ScienceDirect, a manufacturer's spec sheet, a review site that quotes the page.

On the Linux servers (swarm*) the chain ends at step 2: there is no user browser there.

## Using webread

```bash
webread <url>                   # Markdown on stdout
webread <url> --max-chars 20000 # cut long pages (product pages can run to 40k+ characters)
webread <url> --json            # method, status, title, final_url, structured data, markdown, steps tried
webread <url> --raw             # the HTML, e.g. to parse something specific
webread <url> --no-archive      # live page or nothing; never an old Wayback copy
```

- **Steps:** a browser-like HTTP request (about 1 s), then headless Camoufox, an anti-detect Firefox (about 25 s;
  the first run downloads the browser), then the newest Wayback Machine copy. It decides a page is blocked from
  the content, not just the status code. The step that worked is remembered per site and tried first next time.
- **Archived copies** start with a line giving the capture date. Say so when you use one, and don't present its
  prices, stock or other live details as current.
- **Exit codes:** 0 read, 2 blocked at every step (go to step 3 or 4), 1 other errors (bad URL, network down).
- It runs one page per call. For several pages on one site, call it once per page and keep the pace slow (a few
  pages, not a crawl). Don't loop over hundreds of URLs.
- Check that the Markdown is the page you wanted: a site may redirect a bad or old URL to its homepage or another
  item. `--json` shows `final_url`.

## Site notes

- **Reddit:** the normal HTML pages (subreddits, threads) work through the browser step. The `.json` API stays
  blocked. Reddit's `.rss` feeds also work with a plain fetch.
- **ResearchGate, ScienceDirect, TripAdvisor:** DataDome and similar checks; webread gets some pages, not all.
  Prefer another source for papers.
- **Pages behind a login, paywall or CAPTCHA:** webread can't and shouldn't get these. Ask the user.

## What it doesn't do

No CAPTCHA solving, no proxies, never the user's browser profile or cookies, no logins. Reading a few public pages
for research is the intended use. If a site still refuses, respect that and use another source.
