# Dotfiles (chezmoi) — agent notes

## Repo

- chezmoi source for github.com/Syzygianinfern0/dotfiles — **PUBLIC**. Never commit secrets, tokens, internal hostnames/IPs, or employer-internal content (e.g. anything from old internship dotfiles).
- Targets macOS (Homebrew) and Linux servers, including ones with no sudo and no usable Homebrew. Keep the hand-rolled bootstrap (`.chezmoiscripts/run_before_install-tools.sh.tmpl`); don't replace it with a brew-only flow.
- Only trust a Homebrew prefix owned by the current user — a shared linuxbrew makes compinit warn about insecure directories.
- Agent skills live in `dot_ai/skills/` (deployed to `~/.ai/skills/`, which no tool reads). A skill is enabled only by a per-skill link file under `private_dot_claude/skills/` or `private_dot_codex/skills/` — see `dot_ai/skills/README.md`. Don't add links unless asked.
- Docs live in `docs/` (ai, bootstrap, git, secrets, usage); update them when behavior changes.
- Non-repo files in the source dir (README, docs/, assets/, AGENTS.md, CLAUDE.md) must be listed in `.chezmoiignore`, or chezmoi will put them in `~`.

## AI tool settings

- Claude `~/.claude/settings.json` is fully owned by `private_dot_claude/settings.json.tmpl` — changes made in Claude's `/config` get reverted on apply, so put them in the template. ccstatusline hooks are only emitted when ccstatusline is found (Linux: `~/.local/opt/node-*/bin`).
- Codex `~/.codex/config.toml` is NOT owned: `private_dot_codex/modify_private_config.toml` only enforces a few keys and keeps everything Codex writes (trust entries, app state). Never copy the whole Codex config into the repo — its project paths leak personal chat topics.
- ccstatusline config (`dot_config/ccstatusline/settings.json`) is a plain file, same on all machines.
- **Agent parity:** every AI-related addition (skill, script, instruction, setting) must cover both Claude Code and Codex and be written agent-neutrally — the rules are under "Claude Code and Codex parity" in `dot_ai/instructions.md.tmpl`. When enabling a skill, link it for both agents unless the user says otherwise. A setting added to one agent's config gets its counterpart in the other's, or a line in `docs/ai.md` saying why there is none. Known exceptions: `draft-goal-condition` (Codex `/goal`), `cursor-canvas` (Codex + Cursor), the status line (ccstatusline vs. Codex's built-in one).

## Secrets

- age encryption. Identity at `~/.config/chezmoi/key.txt`; passphrase-protected copy in `key.txt.age`.
- Encrypted targets: `encrypted_private_dot_netrc.age`, ssh config. Edit via `chezmoi edit`; never write decrypted content into the source dir.
- Never print credential-helper, netrc, or token output unfiltered.

## Workflow

- Preview with `chezmoi diff` before `chezmoi apply`; report clashes with existing files before overwriting them.
- `chezmoi verify` always fails on the every-run install script — use `chezmoi verify --exclude scripts`.
- Test bootstrap changes in Docker (Ubuntu 22.04, Rocky 8) before rolling out.

## Rollout to servers

After a change lands on `main` and is pushed, roll it out to every machine — not just the Mac:

- Hosts (ssh aliases from the Mac): `swarm1` `swarm2` `swarm3` `swarm4` `swarm5` `swarmllm`. Ubuntu, own home dirs, login shell bash; the managed `~/.bash_profile` (Linux only) hands interactive logins to zsh.
- Each machine needs its name in local chezmoi data (drives the "You are running on" line in `~/.ai/instructions.md`). Set it once with `chezmoi init --promptString machine=<alias>` (`mac` on the laptop); it lives in `~/.config/chezmoi/chezmoi.toml`, never in the repo.
- On each: `chezmoi update`, then `chezmoi verify --exclude scripts`. Pass `GITHUB_TOKEN` over stdin/env (never on the command line) so bootstrap downloads don't hit GitHub API rate limits.
- swarm1 and swarm2 are Ubuntu 20.04 (glibc 2.31): `chezmoi upgrade` there installs a glibc build that won't run. Install the static `linux-musl_amd64` release tarball into `~/bin` instead.
- Report per-host results; a host that fails (e.g. full disk) gets noted for follow-up, not skipped silently.

## Git

- No AI co-author / attribution trailers in commits or PR bodies.
- The pre-Starship setup is preserved on branch `pre-starship` — don't delete it.
