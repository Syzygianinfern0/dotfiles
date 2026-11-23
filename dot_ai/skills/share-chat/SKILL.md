---
name: share-chat
description: Turn a Claude Code or Codex session into a clean, ChatGPT-style share page (the human's messages as bubbles, the agent's final answers as prose, each response's tool calls folded into a "Worked for 2m 14s" dropdown) and publish it to a public Netlify link, through ~/bin/share-chat. Use when the user wants to share, export, publish or send a link to an agent chat or session (this one or another by session ID), see what a session looks like as a page, or take a shared chat down. Not for claude.ai or ChatGPT web chats, which have their own share buttons.
---

# Sharing agent chats

`~/bin/share-chat` reads a session transcript (Claude Code `~/.claude/projects/*/<id>.jsonl` or Codex
`~/.codex/sessions/**/rollout-*.jsonl[.zst]`) and renders one self-contained HTML page. With `--publish` it puts
the page on the user's Netlify chats site and prints the link.

## Which session

- **This conversation:** run it with no session argument from the session's working directory. It picks the newest
  Claude Code or Codex session for the current folder, which is the running one. If the agent has its own session ID
  handy, pass it to be sure.
- **Another session:** pass its ID (a Claude UUID or the Codex rollout ID) or a path to the `.jsonl`. `chat2md <id>`
  shows a session as Markdown if you need to check it's the right one.
- Transcripts are per machine. A session from another host is only found on that host.

## Workflow

1. **Preview locally first** unless the user asked straight for a link:
   `share-chat <id> -o <folder>/<name>.html`, then open it for the user (`open` on the Mac). Put the file in the
   project folder, not in a temp or scratch directory, if the user may want to keep it.
2. **Scan:** `share-chat <id> --check` lists likely secrets (API keys, tokens, private keys, password assignments,
   via built-in patterns plus `gitleaks` when installed) and every email address on the page. Show the user what it
   found. Remove things with `--redact "<string>"` (repeatable; replaced by •••), cut turns with `--turns 1-3,6`,
   or drop all tool activity with `--no-steps`. The user's home folder becomes `~` and their username `user`
   automatically.
3. **Confirm before publishing.** The link is public: anyone who has it can read the whole page, including
   expanded tool output. Say so, list the scan findings, and wait for a clear yes. The paths are unguessable and the
   site has `noindex` + `robots.txt`, but it is not private.
4. **Publish:** `share-chat <id> --publish` (add the same `--redact`/`--turns`/`--no-steps`/`--title` options).
   It exits with code 3 and publishes nothing if the scan finds anything; rerun with `--redact` to fix it, or
   `--force` only after the user has seen the findings and said the page is fine as is. It prints the URL on stdout.
   Check it with `curl -s -o /dev/null -w "%{http_code}\n" <url>` (expect 200) and give the user the link.
5. Publishing the same session again updates the page at the same link.

## Other commands

```bash
share-chat --list                 # published chats: URL, title, session ID
share-chat <id> --unpublish       # delete the page and redeploy (the link stops working)
share-chat <id> --title "Camera search for a friend" --publish
```

## Setup and where things live

- **Netlify:** publishing uses `npx netlify-cli` with the user's own login (see the `netlify-publish` skill if the
  CLI isn't logged in; the user has to run `npx netlify-cli login` themselves). The first `--publish` creates one
  site named `chats-<random>`; its ID and the session → link map are kept in `~/.config/share-chat/config.json`.
- **Local copy of the site:** `~/.local/share/share-chat/site/<slug>/index.html`. Every deploy uploads that whole
  folder, so don't delete it: a deploy without a page takes that page down. Override with `SHARE_CHAT_SITE`.
- Both the config and the site folder are per machine. Publish from the Mac so all links stay in one site and one
  folder; on a server, `--publish` would create a separate site there.

## What the page shows

- Each user message is a bubble (warm for Claude Code, navy for Codex). Messages typed while the agent was working
  get their own bubble.
- Each response opens with a grey "Worked for 3m 42s ›" line (timed from the transcript). It hides the progress
  notes and every step; each step expands to show the command and output, a subagent's prompt and report, or a
  screenshot. Only the final answer stays visible.
- A background agent finishing shows as a small "✓ Agent '…' finished" line.
- Claude Code rarely stores readable thinking, and Codex keeps only short reasoning summaries, so "Thinking" steps
  are usually missing.
- Light and dark mode follow the viewer's system; the layout works on phones.
