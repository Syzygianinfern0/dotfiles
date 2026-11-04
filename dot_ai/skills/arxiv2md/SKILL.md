---
name: arxiv2md
description: Convert arXiv papers to clean Markdown. Use when the user wants to read, fetch, or summarize an arXiv paper.
---

# arxiv2md

Convert arXiv papers to LLM-ready Markdown. Parses arXiv's native HTML (not PDFs) for clean output with proper math, tables, and section structure.

## REST API (preferred for agents)

Base URL: `https://arxiv2md.org`

No auth required. Rate limit: 30 requests/minute.

### Get markdown

```bash
curl "https://arxiv2md.org/api/markdown?url=2501.11120"
```

Returns raw markdown as plain text.

### Get JSON (with metadata)

```bash
curl "https://arxiv2md.org/api/json?url=2501.11120"
```

Returns `{ "arxiv_id", "title", "source_url", "content" }`.

### Parameters

All optional query params for both endpoints:

| Param | Default | Description |
|-------|---------|-------------|
| `url` | required | arXiv URL or ID (e.g. `2501.11120v1` or `https://arxiv.org/abs/2501.11120`) |
| `remove_refs` | `true` | Remove references section |
| `remove_toc` | `true` | Remove table of contents |
| `remove_citations` | `true` | Remove inline citations |
| `frontmatter` | `false` | Prepend YAML metadata (`/api/markdown` only) |

### Examples

```bash
# Get just abstract and introduction
curl "https://arxiv2md.org/api/markdown?url=2501.11120"

# Keep references and citations intact
curl "https://arxiv2md.org/api/markdown?url=2501.11120&remove_refs=false&remove_citations=false"

# JSON with metadata
curl "https://arxiv2md.org/api/json?url=https://arxiv.org/abs/2501.11120v1"

# With frontmatter (title, authors, date as YAML header)
curl "https://arxiv2md.org/api/markdown?url=2501.11120&frontmatter=true"
```

## CLI

```bash
pip install arxiv2markdown

# Output to file
arxiv2md 2501.11120v1 -o paper.md

# Output to stdout
arxiv2md 2501.11120v1 -o -

# Only specific sections
arxiv2md 2501.11120v1 --section-filter-mode include --sections "Abstract,Introduction" -o -

# Strip refs and TOC
arxiv2md 2501.11120v1 --remove-refs --remove-toc -o -

# With YAML frontmatter
arxiv2md 2501.11120v1 --frontmatter -o paper.md
```
