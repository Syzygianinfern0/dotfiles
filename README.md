<div align="center">

# Dotfiles

<samp> My dots managed using [`Chezmoi`](https://www.chezmoi.io/) </samp>

</div>

zsh + [Starship](https://starship.rs) with a small plugin set (fast-syntax-highlighting, zsh-autocomplete, zsh-autosuggestions), fzf, zoxide, eza and bat. Works on macOS, linuxbrew, and Linux hosts without brew/sudo.

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

`chezmoi apply` runs a bootstrap that installs the tool stack: via Homebrew when available (installed automatically on macOS), otherwise into `~/.local/bin` with plugins in `~/.local/share/zsh/plugins` (no sudo). Install failures never abort the apply. On first apply you'll be asked for the passphrase that unlocks the age key (chezmoi's built-in age is used, so no separate `age` install is needed).

## Machine-local files (not synced)

- `~/.config/zsh/env.local` — sourced by `.zshenv` (every shell)
- `~/.config/zsh/secrets.zsh` — sourced by `.zshrc`
- `~/.config/zsh/local.zsh` — sourced last by `.zshrc`, for per-host overrides
