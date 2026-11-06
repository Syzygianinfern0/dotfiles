# Using it

## Shortcuts

| Keys / command | Does |
| --- | --- |
| `Ctrl-R` | fuzzy-search history (fzf) |
| `Ctrl-T` | fuzzy-pick a file and insert its path |
| `Alt-C` | fuzzy-pick a subdirectory and cd into it |
| `Ctrl-Space` | accept the grey autosuggestion |
| `↑` | history menu (zsh-autocomplete) |
| `Option-Backspace` | delete one path segment or word |
| `z foo` · `zi foo` · `z -` | jump to a frequent folder matching `foo` · pick from matches · go back |

Start a command with a space to keep it out of history.

## Aliases and functions

| Command | Does |
| --- | --- |
| `ls` · `ll` · `la` · `lt` | eza: list · long · long incl. hidden · tree |
| `cat` | bat without paging |
| `df` | duf |
| `tn name` · `ta name` · `tl` | tmux new · attach · list sessions |
| `Shift-←/→` (in tmux) | move the current window left/right |
| `brewup` | brew update + upgrade + cleanup |
| `dji_merge` | concatenate the DJI `.MP4` clips in this folder |
| `dji_chapters` | print chapter timestamps for those clips |

## Scripts in `~/bin`

`~/bin` (first on PATH) holds personal scripts, tracked in the repo under `bin/`:

| Command | Does |
| --- | --- |
| `chat2md [session-id] [-o out.md]` | print a Claude Code or Codex session as Markdown: human messages and final replies only (default: latest session of either agent in this folder; reads Codex's `.jsonl.zst` with Python 3.14+ or the `zstd` command) |
| `check-swarm5-ssh [host] [interval]` | poll until `host` (default `swarm5`) accepts ssh, then notify |

## Machine-local overrides

Not tracked; sourced if present:

- `~/.config/zsh/env.local`: read by `.zshenv`, so every shell (scripts too). Good for env vars and PATH.
- `~/.config/zsh/local.zsh`: read last by `.zshrc`. Good for per-host aliases, secrets and tweaks.
- `~/.config/bash/local.bash` (Linux): read last by an interactive `.bashrc`.

## Bash on the servers

The servers' login shell is bash. The managed `~/.bash_profile` hands a plain `ssh host` session to zsh, but stays in bash for `bash -lc cmd`, `ssh host cmd`, agent backends (Codex, Cursor) and sessions without a terminal, so their commands still run. `~/.bashrc` puts `~/bin` and `~/.local/bin` on PATH first, so `ssh host uv ...` works too. If zsh is missing, the login stays in bash instead of disconnecting.

## Everyday chezmoi

```sh
chezmoi update                  # pull the repo and apply
chezmoi edit --apply ~/.zshrc   # edit a managed file and apply it
chezmoi diff                    # preview what apply would change
chezmoi re-add                  # copy local edits of managed files back into the repo
chezmoi cd                      # open a shell in the repo, then use git as usual
```

To roll a machine back to the old setup: `chezmoi git checkout pre-starship && chezmoi apply` (and `checkout main` to return).
