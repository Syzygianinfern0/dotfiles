# AI coding agents

The repo sets up two agents, [Claude Code](https://claude.com/claude-code) and [Codex](https://developers.openai.com/codex), so they share the same instructions and skills but keep their own settings. Neither CLI is installed by the bootstrap; install them yourself on the machines where you use them.

## Layout

```
~/.ai/                         shared, agent-neutral
├── instructions.md            ← dot_ai/instructions.md.tmpl
└── skills/<name>/             ← dot_ai/skills/   (off until linked, see below)

~/.claude/                     Claude Code
├── CLAUDE.md  → ../.ai/instructions.md
└── settings.json              ← private_dot_claude/settings.json.tmpl   (fully owned)

~/.codex/                      Codex
├── AGENTS.md  → ../.ai/instructions.md
└── config.toml                ← private_dot_codex/modify_private_config.toml   (a few keys enforced)

~/bin/chat2md                  ← bin/executable_chat2md   (read past sessions of either agent)
~/bin/panel-ask                ← bin/executable_panel-ask (run a cross-family model panel)
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
| Managed by | full template | modify script that sets a few keys |
| Changes made in the app (`/config`, settings UI) | **reverted** on the next `chezmoi apply`; make them in the template | kept, unless they touch an enforced key |
| Why | the file holds only preferences | Codex also writes trust entries and app state there, including project paths that must not end up in this public repo |

Enforced for **Claude**: model and effort (per model), theme, `cleanupPeriodDays: 365` (keep transcripts a year), `idleCompaction: false`, skip the bypass-mode confirmation, and the status line below.

Enforced for **Codex**: model and reasoning effort, multi-agent and memories features, the built-in status line items, and the OpenAI developer-docs MCP server.

Not managed for either: MCP servers and plugins you add in the apps, command allow rules (`~/.codex/rules/`), login state.

## Status line

- **Codex** uses its built-in status line (`tui.status_line` in the config).
- **Claude** uses [ccstatusline](https://github.com/sirmalloc/ccstatusline), configured by [`dot_config/ccstatusline/settings.json`](../dot_config/ccstatusline/settings.json) (the same on every machine). ccstatusline is a Node script: on macOS it comes from Homebrew; on Linux the template looks for it under `~/.local/opt/node-*/bin/`. If it isn't found, the status line and its hooks are simply left out of `settings.json`. Nothing installs Node or ccstatusline on Linux yet.

## Memory

Each agent keeps its own memory, outside the repo: Claude under `~/.claude/projects/<project>/memory/`, Codex under `~/.codex/memories/`. Neither is synced between machines.

## Model panels

The `with-the-power-of-friendship` skill has the agent moderate a panel of Claude Opus, Claude Fable, GPT-6 Astra and GPT-6.1 Sol: independent first answers, then anonymized cross-critique, then a decision memo with the surviving dissent. Every seat, from either family, goes through `~/bin/panel-ask`, which calls `claude -p` or `codex exec` read-only, resumes seats by session id in later rounds, and logs status and cost to the panel directory. It needs both CLIs logged in on the machine. Seat names map to model slugs at the top of the script.

```sh
panel-ask seats                       # known seats
panel-ask run <dir> 1 [seat ...]      # run round 1 from <dir>/round1.md
panel-ask label <dir> 1               # anonymous labels for the round-1 answers
panel-ask pack <dir> 1                # round-2 briefs from <dir>/round2_head.md + answers
panel-ask run <dir> 2                 # round 2, resuming each seat
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

## Adding something new

Skills, scripts, instructions and settings should work the same in both agents. Write them agent-neutrally: "the agent" rather than a product name, no tool names that only one agent has, shared files in `~/.ai/` or `~/bin`, and both `~/.claude` and `~/.codex` handled when reading agent data. A setting for one agent gets its counterpart in the other, or a note here on why there isn't one. Both agents are told this in the shared instructions.

Current exceptions, because only one agent has the feature: the `draft-goal-condition` skill (Codex `/goal`), the `cursor-canvas` skill (Codex + Cursor), and the status line (ccstatusline for Claude, built-in for Codex).

## Rolling out a change

After pushing to `main`, run `chezmoi update` and `chezmoi verify --exclude scripts` on every machine, as with any other change (see [`AGENTS.md`](../AGENTS.md)).
