# Secrets

Private files are encrypted with [age](https://age-encryption.org), using chezmoi's built-in support, so you don't need to install `age`.

- `key.txt.age` is the age key, protected by a passphrase. On the first apply it's decrypted once to `~/.config/chezmoi/key.txt` (readable only by you). To set up a machine without typing the passphrase, copy that file over yourself before the first apply.
- `~/.netrc` (includes the wandb key, which wandb reads from there itself), `~/.ssh/config` and every file in `~/.config/secrets/` are stored encrypted with that key.

To add another encrypted file: `chezmoi add --encrypt <file>`.

## API keys for jobs and agents: `with-secret`

API keys live in `~/.config/secrets/<purpose>.env`, one file per purpose (directory 700, files 600). The first line is a `# description` and the rest are `KEY=VALUE` lines. A purpose is what the key is for (`imagegen`, `openai-research`), not which provider it's from, so a key meant for one job isn't picked up by another.

- `with-secret --add <purpose>`: run it in your own terminal. It asks for a description, then each variable name and its value, with the value hidden. Then it encrypts the file into this repo (`chezmoi add --encrypt`), commits it and pushes. Other machines get it with `chezmoi update`. Running it again on an existing purpose replaces that purpose.
- `with-secret --list`: lists the purposes on this machine, with their variable names and descriptions, never the values.
- `with-secret <purpose> -- <command>`: runs the command with only that purpose's keys. It first removes every variable that any purpose defines from the environment, so a stray export can't leak in. Files are parsed as data, never sourced. For long jobs, run it inside tmux: `tmux new -d -s job 'with-secret <purpose> -- python run.py'`.
- To edit a key by hand: `chezmoi edit ~/.config/secrets/<purpose>.env`, then commit and push.
- To remove a purpose: `chezmoi forget ~/.config/secrets/<purpose>.env`, delete the file, and add its path to `.chezmoiremove` so other machines delete it too.

Nothing exports keys in shell startup files. The agent instructions (`dot_ai/instructions.md.tmpl`, under "API keys") tell both agents to get keys only through `with-secret` and to ask when no purpose clearly fits. `imagegen` reads its own `imagegen` purpose file directly. `.chezmoiremove` deletes the old `~/.config/imagegen.env` location.

Not stored at all: `~/.config/rclone/rclone.conf`, which holds cloud-drive login tokens. The bootstrap installs `rclone`; run `rclone config` once on each machine that needs a remote.

## Keeping the public repo clean

This repo is public. GitHub secret scanning with push protection is on, so pushes containing known token formats are blocked. For a local check before committing, opt in to the gitleaks hook in [`.pre-commit-config.yaml`](../.pre-commit-config.yaml) with `pre-commit install`.
