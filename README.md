<div align="center">

# Dotfiles

<samp> My dots managed using [`Chezmoi`](https://www.chezmoi.io/) </samp>

</div>

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
~/bin/install_dots.sh
```
