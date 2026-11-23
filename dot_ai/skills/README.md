# Skills

All skills live here and deploy to `~/.ai/skills/`. Neither Claude nor Codex reads this folder, so a skill is **off** until linked.

To turn one on, add a one-line link file containing `../../.ai/skills/<name>`:

- Claude: `private_dot_claude/skills/symlink_<name>`
- Codex: `private_dot_codex/skills/symlink_<name>`

Delete the link file to turn it off again. Currently linked (both agents): `with-the-power-of-friendship`, `netlify-publish`, `imagegen`, `weekly-report`, `webread`, `share-chat`.

| Skill | Origin | Notes |
|---|---|---|
| arxiv2md | old setup, Mac Codex | SKILL.md only; the arxiv2md source project itself isn't vendored |
| commit-planner | old setup | |
| long-running-experiment-ops | old setup, Mac Codex | |
| peer-review-idea-loop | old setup, Mac Codex | |
| cluster-compute | swarm5 Codex | |
| draft-goal-condition | old setup, Mac Codex | Codex-specific (`/goal`) |
| cursor-canvas | old setup, Mac Codex | Codex + Cursor Canvas specific |
| with-the-power-of-friendship | swarm5 Claude Code, 2026-11-06 | Uses `~/bin/panel-ask` (needs both `claude` and `codex` CLIs) |
| netlify-publish | Mac Claude Code, 2026-11-08 | Uses `npx netlify-cli`; login token stays in the CLI's own config, not here |
| imagegen | swarm5 Claude Code, 2026-11-12 | Uses `~/bin/imagegen` (OpenAI + Gemini image APIs); keys in the `imagegen` secret purpose, `~/.config/secrets/imagegen.env`, stored age-encrypted (`dot_config/private_secrets/encrypted_private_imagegen.env.age`) |
| weekly-report | swarm5 Claude Code, 2026-11-16 | One-page LaTeX advisor report; reports live in `~/code/weekly-reports`; needs `latexmk`, `pdfinfo`, `chat2md` |
| webread | Mac Claude Code, 2026-11-16 | Uses `~/bin/webread` (curl_cffi → headless Camoufox → Wayback); browser step needs no sudo but downloads Camoufox on first use |
| share-chat | Mac Claude Code, 2026-11-22 | Uses `~/bin/share-chat` (renders a session as a ChatGPT-style page; `--publish` deploys to one Netlify site via `npx netlify-cli`); site ID and links in `~/.config/share-chat/config.json`, local site copy in `~/.local/share/share-chat/site` |
