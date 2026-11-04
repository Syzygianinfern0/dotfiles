# Dotfiles (chezmoi) — agent notes

## Repo

- chezmoi source for github.com/Syzygianinfern0/dotfiles — **PUBLIC**. Never commit secrets, tokens, internal hostnames/IPs, or employer-internal content (e.g. anything from old internship dotfiles).
- Targets macOS (Homebrew) and Linux servers, including ones with no sudo and no usable Homebrew. Keep the hand-rolled bootstrap (`.chezmoiscripts/run_before_install-tools.sh.tmpl`); don't replace it with a brew-only flow.
- Only trust a Homebrew prefix owned by the current user — a shared linuxbrew makes compinit warn about insecure directories.
- Agent skills live in `dot_ai/skills/` (deployed to `~/.ai/skills/`, which no tool reads). A skill is enabled only by a per-skill link file under `private_dot_claude/skills/` or `private_dot_codex/skills/` — see `dot_ai/skills/README.md`. Don't add links unless asked.
- Docs live in `docs/` (bootstrap, git, secrets, usage); update them when behavior changes.
- Non-repo files in the source dir (README, docs/, assets/, AGENTS.md, CLAUDE.md) must be listed in `.chezmoiignore`, or chezmoi will put them in `~`.

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

- Hosts (ssh aliases from the Mac): `swarm1` `swarm2` `swarm3` `swarm4` `swarm5` `swarmllm`. Ubuntu, own home dirs, login shell bash with `exec zsh` in `~/.bash_profile`.
- Each machine needs its name in local chezmoi data (drives the "You are running on" line in `~/.ai/instructions.md`). Set it once with `chezmoi init --promptString machine=<alias>` (`mac` on the laptop); it lives in `~/.config/chezmoi/chezmoi.toml`, never in the repo.
- On each: `chezmoi update`, then `chezmoi verify --exclude scripts`. Pass `GITHUB_TOKEN` over stdin/env (never on the command line) so bootstrap downloads don't hit GitHub API rate limits.
- Report per-host results; a host that fails (e.g. full disk) gets noted for follow-up, not skipped silently.

## Git

- No AI co-author / attribution trailers in commits or PR bodies.
- The pre-Starship setup is preserved on branch `pre-starship` — don't delete it.
