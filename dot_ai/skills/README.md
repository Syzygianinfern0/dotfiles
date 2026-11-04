# Skills

All skills live here and deploy to `~/.ai/skills/`. Neither Claude nor Codex reads this folder, so a skill is **off** until linked.

To turn one on, add a one-line link file containing `../../.ai/skills/<name>`:

- Claude: `private_dot_claude/skills/symlink_<name>`
- Codex: `private_dot_codex/skills/symlink_<name>`

Delete the link file to turn it off again. Currently none are linked.

| Skill | Origin | Notes |
|---|---|---|
| arxiv2md | old setup, Mac Codex | SKILL.md only; the arxiv2md source project itself isn't vendored |
| commit-planner | old setup | |
| long-running-experiment-ops | old setup, Mac Codex | |
| peer-review-idea-loop | old setup, Mac Codex | |
| cluster-compute | swarm5 Codex | |
| draft-goal-condition | old setup, Mac Codex | Codex-specific (`/goal`) |
| cursor-canvas | old setup, Mac Codex | Codex + Cursor Canvas specific |
