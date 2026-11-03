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

- Install age for encryption
```shell
wget -qO- "https://gist.githubusercontent.com/Syzygianinfern0/97b77bff7ef4865f29f030444558dccd/raw/install_age.sh" | bash
export PATH=$HOME/bin:$PATH
```

- Install dotfiles
```shell
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Syzygianinfern0
```

`chezmoi apply` runs a bootstrap that installs the tool stack: via Homebrew when available (installed automatically on macOS), otherwise into `~/.local/bin` with plugins in `~/.local/share/zsh/plugins` (no sudo). Install failures never abort the apply.

## Machine-local files (not synced)

- `~/.config/zsh/env.local` — sourced by `.zshenv` (every shell)
- `~/.config/zsh/secrets.zsh` — sourced by `.zshrc`
- `~/.config/zsh/local.zsh` — sourced last by `.zshrc`, for per-host overrides
