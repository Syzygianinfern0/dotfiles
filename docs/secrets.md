# Secrets

Private files are encrypted with [age](https://age-encryption.org), using chezmoi's built-in support, so you don't need to install `age`.

- `key.txt.age` is the age key, protected by a passphrase. On the first apply it's decrypted once to `~/key.txt`.
- `~/.netrc` and `~/.ssh/config` are stored encrypted with that key.

To add another encrypted file: `chezmoi add --encrypt <file>`.

## Keeping the public repo clean

This repo is public. GitHub secret scanning with push protection is on, so pushes containing known token formats are blocked. For a local check before committing, opt in to the gitleaks hook in [`.pre-commit-config.yaml`](../.pre-commit-config.yaml) with `pre-commit install`.
