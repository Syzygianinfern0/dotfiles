# How tools get installed

Every `chezmoi apply` first runs [`run_before_install-tools.sh`](../.chezmoiscripts/run_before_install-tools.sh.tmpl):

- **macOS:** installs Homebrew if it's missing, then the tools, Ghostty and the Meslo Nerd Font.
- **Linux with brew:** uses linuxbrew. If that fails (say, a read-only shared install), it falls through to the next mode.
- **Linux without brew:** downloads release binaries into `~/.local/bin` and clones the zsh plugins into `~/.local/share/zsh/plugins`. No sudo needed. A binary that won't run on the host (for example, built for a newer glibc) is removed again.

The script exits right away when everything is already installed, retries anything that failed on the next apply, and never stops the apply. The shell config checks for each tool before using it, so a partial install still gives you a working shell.

On shared login nodes, `export GITHUB_TOKEN=...` before applying so the downloads don't hit GitHub's API rate limit.

## Repo map

```
.chezmoiscripts/run_before_install-tools.sh.tmpl   tool installer
dot_zshenv · dot_zprofile                          PATH and brew detection
dot_zshrc · dot_zsh/zsh_aliases                    interactive shell, plugins, aliases
dot_config/starship.toml                           prompt
dot_config/ghostty/config                          terminal
dot_gitconfig.tmpl · dot_config/git/ignore         git
dot_tmux.conf                                      tmux
*.age                                              encrypted files and the key
.chezmoiremove                                     old-setup files to delete on apply
docs/                                              these docs (not installed)
```
