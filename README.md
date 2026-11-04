<div align="center">

# Dotfiles

<samp> My dots managed using [`Chezmoi`](https://www.chezmoi.io/) </samp>

</div>

zsh + [Starship](https://starship.rs) with a small plugin set (fast-syntax-highlighting, zsh-autocomplete, zsh-autosuggestions), fzf, zoxide, eza and bat, plus ripgrep, fd, delta (git pager), gh and jq. [Ghostty](https://ghostty.org) terminal on macOS. Works on macOS, linuxbrew, and Linux hosts without brew/sudo.

## Quick Start

- Basic dependencies for a docker
```shell
apt update
apt install -y git curl zsh
```

- Install dotfiles
```shell
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Syzygianinfern0
```

`chezmoi apply` runs a bootstrap that installs the tool stack (starship, zoxide, fzf, eza, bat, duf, dust, btop, git-lfs, ripgrep, fd, delta, gh, jq + zsh plugins; on macOS also Ghostty and the Meslo Nerd Font): via Homebrew when available (installed automatically on macOS), otherwise into `~/.local/bin` with plugins in `~/.local/share/zsh/plugins` (no sudo). It runs on every apply but exits immediately once everything is present, so failed installs are retried next time; it never aborts the apply. On shared cluster login nodes, `export GITHUB_TOKEN=...` first to avoid GitHub API rate limits.

On first apply you'll be asked for the passphrase that unlocks the age key (chezmoi's built-in age is used, so no separate `age` install is needed).

Git uses `gh` for GitHub credentials on every OS: run `gh auth login` once per machine.

## Machine-local files (not synced)

- `~/.config/zsh/env.local` — sourced by `.zshenv` (every shell)
- `~/.config/zsh/local.zsh` — sourced last by `.zshrc`: per-host overrides and secrets

## Working on this repo

Run `pre-commit install` once per clone; it runs gitleaks to block commits containing secrets.
