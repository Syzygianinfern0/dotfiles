# Secrets

Private files are encrypted with [age](https://age-encryption.org), using chezmoi's built-in support, so you don't need to install `age`.

- `key.txt.age` is the age key, protected by a passphrase. On the first apply it's decrypted once to `~/.config/chezmoi/key.txt` (readable only by you). To set up a machine without typing the passphrase, copy that file over yourself before the first apply.
- `~/.netrc`, `~/.ssh/config` and `~/.config/imagegen.env` (OpenAI and Gemini API keys for `imagegen`) are stored encrypted with that key. Change the keys with `chezmoi edit ~/.config/imagegen.env`.

To add another encrypted file: `chezmoi add --encrypt <file>`.

## Keeping the public repo clean

This repo is public. GitHub secret scanning with push protection is on, so pushes containing known token formats are blocked. For a local check before committing, opt in to the gitleaks hook in [`.pre-commit-config.yaml`](../.pre-commit-config.yaml) with `pre-commit install`.
