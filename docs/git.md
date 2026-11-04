# Git setup

[`.gitconfig`](../dot_gitconfig.tmpl) turns on a few defaults most people end up wanting:

| Setting | Effect |
| --- | --- |
| `pull.rebase`, `rebase.autoStash` | `git pull` rebases your commits instead of making merge commits, stashing uncommitted work around it |
| `push.autoSetupRemote` | the first `git push` of a new branch sets its upstream |
| `fetch.prune` | remote branches deleted upstream disappear locally |
| `merge.conflictStyle = zdiff3` | conflicts also show the original text |
| `diff.algorithm = histogram` | cleaner diffs |
| `rerere.enabled` | git remembers how you resolved a conflict and reuses it |
| `branch.sort = -committerdate` | `git branch` lists recent branches first |

Diffs and logs go through [delta](https://github.com/dandavison/delta) when it's installed, and plain `less` otherwise. Inside delta, `n` / `N` jump between files.

OS and editor junk (`.DS_Store`, swap files, …) is ignored everywhere via `~/.config/git/ignore`.

## Signing in to GitHub

Run `gh auth login` once per machine. Git then gets GitHub credentials from `gh`, on macOS and Linux alike. Other hosts use the macOS keychain, or git's `store` helper on Linux.
