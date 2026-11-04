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

## Machine-local overrides

Not tracked; sourced if present:

- `~/.config/zsh/env.local`: read by `.zshenv`, so every shell (scripts too). Good for env vars and PATH.
- `~/.config/zsh/local.zsh`: read last by `.zshrc`. Good for per-host aliases, secrets and tweaks.

## Everyday chezmoi

```sh
chezmoi update                  # pull the repo and apply
chezmoi edit --apply ~/.zshrc   # edit a managed file and apply it
chezmoi diff                    # preview what apply would change
chezmoi re-add                  # copy local edits of managed files back into the repo
chezmoi cd                      # open a shell in the repo, then use git as usual
```

To roll a machine back to the old setup: `chezmoi git checkout pre-starship && chezmoi apply` (and `checkout main` to return).
