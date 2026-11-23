# AI coding agents

The repo sets up two agents, [Claude Code](https://claude.com/claude-code) and [Codex](https://developers.openai.com/codex), so they share the same instructions and skills but keep their own settings. Neither CLI is installed by the bootstrap; install them yourself on the machines where you use them.

## Layout

```
~/.ai/                         shared, agent-neutral
├── instructions.md            ← dot_ai/instructions.md.tmpl
└── skills/<name>/             ← dot_ai/skills/   (off until linked, see below)

~/.claude/                     Claude Code
├── CLAUDE.md  → ../.ai/instructions.md
└── settings.json              ← private_dot_claude/modify_private_settings.json   (fully owned)

~/.codex/                      Codex
├── AGENTS.md  → ../.ai/instructions.md
└── config.toml                ← private_dot_codex/modify_private_config.toml   (a few keys enforced)

~/bin/chat2md                  ← bin/executable_chat2md   (read past sessions of either agent)
~/bin/panel-ask                ← bin/executable_panel-ask (run a cross-family model panel)
~/bin/imagegen                 ← bin/executable_imagegen  (batch image generation, OpenAI + Gemini)
~/bin/webread                  ← bin/executable_webread   (read pages that block bots; HTTP → Camoufox → Wayback)
~/bin/share-chat              ← bin/executable_share-chat (agent session → share page, optional Netlify publish)
```

`~/.claude` and `~/.codex` are created with mode 700.

## Shared instructions

`~/.ai/instructions.md` is the one set of user-level instructions both agents read (Claude as `CLAUDE.md`, Codex as `AGENTS.md`). Edit [`dot_ai/instructions.md.tmpl`](../dot_ai/instructions.md.tmpl), not the deployed file.

It contains a "You are running on: …" line built from a per-machine `machine` value, so an agent knows which host it's on and doesn't ssh to itself. Set it once per machine (it lives in `~/.config/chezmoi/chezmoi.toml`, never in the repo):

```sh
chezmoi init --promptString machine=mac      # or the host's ssh alias
```

Project-level instructions stay in each repo (`AGENTS.md`, with a `CLAUDE.md` containing `@AGENTS.md` so Claude reads the same file).

## Skills

Skills live in [`dot_ai/skills/`](../dot_ai/skills/) and deploy to `~/.ai/skills/`, which neither agent reads, so every skill is **off** until you link it for an agent. See [the skills README](../dot_ai/skills/README.md) for how to turn one on and which skills are agent-specific.

Both agents read `SKILL.md` (its `name` and `description` frontmatter decide when the skill is used). Codex additionally reads an optional `agents/openai.yaml`, which only sets how the skill looks in Codex's skill picker (display name, short description, a starter prompt); Claude ignores it.

## Settings

The two config files are handled differently on purpose:

| | Claude `~/.claude/settings.json` | Codex `~/.codex/config.toml` |
| --- | --- | --- |
| Managed by | modify template that writes the whole file | modify script that sets a few keys |
| Changes made in the app (`/config`, settings UI) | **reverted** on the next `chezmoi apply`; make them in the template | kept, unless they touch an enforced key |
| Why | the file holds only preferences | Codex also writes trust entries and app state there, including project paths that must not end up in this public repo |

Enforced for **Claude**: model and effort (per model), theme, `cleanupPeriodDays: 365` (keep transcripts a year), `idleCompaction: false`, skip the bypass-mode confirmation, and the status line below. Its `env` block sets `CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION` to 2000 (Claude Code's default is 200 WebSearch calls per session, shared with subagents). Codex has no counterpart: it has no per-session web search cap to raise.

One exception, on the machine named `mac` only: if OpenAIDR has added its hooks to the file (commands containing `openaidr-hook-v1`), those hook entries and the `env` block it adds (telemetry to a local collector) are copied over as they are (with the enforced env vars above merged in first), so `chezmoi apply` doesn't remove them. Nothing of them is stored in the repo. Codex has no counterpart in the repo: OpenAIDR puts its Codex hooks in `~/.codex/hooks.json`, which isn't managed, and `config.toml` keeps whatever Codex writes anyway.

Enforced for **Codex**: model and reasoning effort, subagents (`agents.enabled = true`) and memories features, the built-in status line items, and the OpenAI developer-docs MCP server. The deprecated `features.multi_agent` key is removed on apply; subagent implementation selection uses the client's defaults. Claude Code enables subagents without an equivalent configuration switch.

Not managed for either: MCP servers and plugins you add in the apps, command allow rules (`~/.codex/rules/`), login state.

## Status line

- **Codex** uses its built-in status line (`tui.status_line` in the config).
- **Claude** uses [ccstatusline](https://github.com/sirmalloc/ccstatusline), configured by [`dot_config/ccstatusline/settings.json`](../dot_config/ccstatusline/settings.json) (the same on every machine). ccstatusline is a Node script: on macOS it comes from Homebrew; on Linux the template looks for it under `~/.local/opt/node-*/bin/`. If it isn't found, the status line and its hooks are simply left out of `settings.json`. Nothing installs Node or ccstatusline on Linux yet.

## Memory

Each agent keeps its own memory, outside the repo: Claude under `~/.claude/projects/<project>/memory/`, Codex under `~/.codex/memories/`. Neither is synced between machines.

## Model panels

The `with-the-power-of-friendship` skill has the agent moderate a panel of Claude Opus 5.5, Claude Fable 5.2, GPT-6 Astra and GPT-6.1 Sol: independent first answers, then anonymized cross-critique, then a decision memo with the surviving dissent. Every seat, from either family, goes through `~/bin/panel-ask`, which calls `claude -p` or `codex exec` read-only, resumes seats by session id in later rounds, and logs status and cost to the panel directory. Codex seats run with `--ignore-user-config` and the apps/plugins features off, so they get no MCP servers or connectors; their cost is computed from token usage at LiteLLM list prices (catalog cached daily in `~/.cache/panel-ask/`). Web access is off for all seats unless `run` gets `--web`, which gives Claude seats WebSearch/WebFetch and Codex seats live web search (Codex otherwise searches by default, so it is set to `web_search="disabled"`). It needs both CLIs logged in on the machine. Seat names map to exact model ids at the top of the script (`SEATS`); every seat runs at `--effort high` unless `run` gets `--effort` (Codex has no `max`, so it maps to `xhigh`).

```sh
panel-ask seats                       # known seats
panel-ask run <dir> 1 [seat ...]      # run round 1 from <dir>/round1.md
panel-ask label <dir> 1               # anonymous labels for the round-1 answers
panel-ask pack <dir> 1                # round-2 briefs from <dir>/round2_head.md + answers
panel-ask run <dir> 2                 # round 2, resuming each seat
panel-ask run <dir> 1 --web           # let every seat search the web (pass it every round)
```

Isolation differs by family: Codex seats run in Codex's read-only sandbox; Claude seats get only Read, Grep and Glob under `--restricted`, with no MCP servers or skills. Claude reports cost per call; Codex cost is recorded as unknown.

## Reading past sessions

`chat2md` prints a Claude Code or Codex session as compact Markdown: what you typed and the agent's final reply for each turn, without tool calls or injected context. The shared instructions tell both agents about it, so you can say "read session `<id>`" in a new chat.

```sh
chat2md                    # newest session of either agent in this folder
chat2md <session-id>       # any session on this machine, Claude or Codex
chat2md -o notes.md <id>   # write to a file
```

| | Claude Code | Codex |
| --- | --- | --- |
| Where sessions are | `~/.claude/projects/<folder>/<id>.jsonl` | `~/.codex/sessions/YYYY/MM/DD/rollout-…-<id>.jsonl[.zst]` and `~/.codex/archived_sessions/` |
| Find an ID | `/status`, or `claude --resume` | `codex resume`, or the file name |

Transcripts are per machine, so `chat2md` only finds sessions from the host it runs on. Codex compresses most logs with zstd; reading them needs Python 3.14+ or the `zstd` command.

## Image generation

The `imagegen` skill tells the agent when a generated image fits (illustrations, teasers, concept art) and when to draw with code instead (plots, diagrams, tables). It runs `~/bin/imagegen`, a `uv` script that sends each figure in a prompts YAML to OpenAI and Gemini image models in parallel, keeps every variant, logs prompts, models, token usage and an estimated cost (from LiteLLM's public price catalog, cached daily in `~/.cache/imagegen/`) to `manifest.json` and builds a contact sheet. API keys come from the `imagegen` secret purpose, `~/.config/secrets/imagegen.env`, which chezmoi deploys age-encrypted (see [secrets](secrets.md)). Default model ids are at the top of the script; `imagegen --list-models` shows what the keys can reach.

```sh
imagegen figures.yaml --quote       # this run's estimated cost on every available model
imagegen figures.yaml --dry-run     # jobs, output dir and estimated cost
imagegen figures.yaml               # both backends, n variants each
imagegen -p "..." --id name         # one-off prompt
```

## Adding something new

Skills, scripts, instructions and settings should work the same in both agents. Write them agent-neutrally: "the agent" rather than a product name, no tool names that only one agent has, shared files in `~/.ai/` or `~/bin`, and both `~/.claude` and `~/.codex` handled when reading agent data. A setting for one agent gets its counterpart in the other, or a note here on why there isn't one. Both agents are told this in the shared instructions.

Current exceptions, because only one agent has the feature: the `draft-goal-condition` skill (Codex `/goal`), the `cursor-canvas` skill (Codex + Cursor), and the status line (ccstatusline for Claude, built-in for Codex).

## Rolling out a change

After pushing to `main`, run `chezmoi update` and `chezmoi verify --exclude scripts` on every machine, as with any other change (see [`AGENTS.md`](../AGENTS.md)).

## Reading blocked web pages

The shared instructions tell both agents that when a page fetch is blocked (403, "Access Denied", a challenge page) they should run `~/bin/webread <url>` before giving up; the `webread` skill has the full chain. `webread` is a `uv` script that tries a browser-like HTTP request with Chrome's TLS fingerprint (`curl_cffi`), then headless Camoufox (an anti-detect Firefox, downloaded on first use to its own cache), then the newest Wayback Machine copy (labelled with its capture date). It judges blocks from the page content, prints clean Markdown via trafilatura with any JSON-LD first, and remembers per site which step worked (`~/.cache/webread/sites.json`). Exit code 2 means blocked at every step; on the Mac the agent may then use the user's own browser after telling them, on the servers it looks for another source. The choice of tools came from a Nov 2026 comparison of about 25 free stealth browsers and toolkits: integrated toolkits (Scrapling, Crawl4AI, stealth MCP servers) added no coverage over this chain. It never touches the user's browser profile, solves CAPTCHAs or uses proxies.

```
webread <url>                 # Markdown on stdout, status on stderr
webread <url> --json          # method, status, final_url, structured data, markdown
webread <url> --no-archive    # live page or nothing
```

The shared instructions also warn agents that drive Chrome through the browser extension not to close their last own tab while they still need a tab the user added to the group: closing it removes the whole group (confirmed in a test on 2026-11-17). Only Claude Code has these tools, so the rule has no Codex counterpart.

## Sharing chats

`~/bin/share-chat` (the `share-chat` skill) is a `uv` script that renders a Claude Code or Codex session as one self-contained page in the style of a ChatGPT share link: the human's messages as bubbles, the agent's final answers as prose, and each response's progress notes and tool steps folded into a "Worked for 3m 42s" dropdown whose steps expand to show commands, outputs, subagent reports and screenshots. It parses both transcript formats (including zstd-compressed Codex rollouts) into one model, highlights code with Pygments at build time, follows the viewer's light/dark setting, and replaces the home folder with `~` and the username with `user`. It was built after a Nov 2026 survey of existing exporters (claude-replay, claude-code-log, simonw's claude-code-transcripts, chat2html, codex-transcript-viewer): none produced a page that read like a chat share.

`--publish` puts the page on one Netlify site, created on first use as `chats-<random>`, under an unguessable path (`<title-slug>-<6 hex>`); the site serves `noindex` and a `robots.txt` that disallows everything, and the root page lists nothing. The site ID and the session → link map live in `~/.config/share-chat/config.json`, and the local copy of the site in `~/.local/share/share-chat/site` (each deploy uploads the whole folder). Both are per machine, so publish from the Mac. Before publishing it scans the page for likely secrets (built-in patterns plus `gitleaks` when installed) and email addresses, and refuses (exit 3) until the findings are redacted or `--force` is given; the skill tells agents to show the findings and get a yes first.

```
share-chat <id> -o page.html            # render only
share-chat <id> --check                 # scan for secrets and emails
share-chat <id> --publish [--redact S] [--turns 1-3] [--no-steps] [--title T]
share-chat --list | share-chat <id> --unpublish
```
