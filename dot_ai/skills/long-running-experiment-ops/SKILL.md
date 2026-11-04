---
name: long-running-experiment-ops
description: Inspect and modify ML, LLM training, finetuning, simulation, or batch-processing codebases so experiments can run unattended for hours or days. Use when Codex is asked to prepare a repository for long-running runs, tmux/SSH operation, crash recovery, resumable training, durable logging, checkpoints, status files, watchdogs, restart scripts, result consolidation, or low-token monitoring.
---

# Long Running Experiment Ops

## Operating Principle

Make the remote machine the durable operator and Codex the supervisor. Implement enough repository support that an experiment can survive agent disconnects, SSH drops, and process crashes without losing state or requiring log streaming.

Prefer the repo's existing training framework, config system, logger, and launcher. Keep changes narrow and reversible.

## Workflow

1. Inspect the repo before editing:
   - Run `scripts/audit_long_running_readiness.py <repo>` from this skill for a first-pass inventory.
   - Search for entrypoints, configs, checkpoint code, logging, experiment trackers, and existing shell launchers.
   - Identify the minimal runnable command and the canonical output directory.

2. Add or adapt durable run artifacts:
   - Stable `run_id` and `run_dir` for every run.
   - Append-only logs on disk, not just console output.
   - Compact `status.json` or `status.yaml` updated atomically with state, step, metrics, checkpoint, PID, timestamps, and last error.
   - Checkpoints sufficient for resume, including optimizer/scheduler/scaler/RNG state when the framework supports it.
   - A machine-readable final summary with config, best metrics, final metrics, checkpoint paths, duration, and failure state if any.

3. Add operational entrypoints when missing:
   - `scripts/run_<name>.sh` or equivalent for a single experiment.
   - `scripts/resume_<name>.sh` or a documented `--resume` flag.
   - `scripts/watch_<name>.sh` only when the user wants unattended restarts without Codex being alive.
   - Optional `tmux` wrapper that creates a named session and writes logs to the run directory.

4. Handle crashes conservatively:
   - Record the traceback and command in the run directory.
   - Restart only when the failure class is known recoverable or the user explicitly requested automatic restarts.
   - Never hide repeated failures behind infinite restarts; cap attempts and write the terminal state.

5. Validate with a cheap run:
   - Prefer dry-run, `--max_steps 1`, tiny dataset, or CPU smoke test.
   - Verify logs, status file, checkpoint/resume path, and final summary are actually created.
   - Do not start an expensive real training job unless the user asked for launch, not just repo preparation.

## Implementation Checklist

Use this as a target, not a rigid template:

- `run_id`: deterministic or explicitly supplied; included in paths and logs.
- `run_dir`: contains config snapshot, command, environment snapshot, logs, status, checkpoints, and summaries.
- `status`: small enough for cheap polling with `cat`; updated atomically via temp file + rename.
- `logging`: console and file logging; no dependence on `tail -f`.
- `checkpoint`: periodic save and resume from latest or specified checkpoint.
- `signals`: handle `SIGTERM`/`SIGINT` when practical by saving status and checkpoint.
- `restart`: capped retry loop for known transient failures if a watchdog is added.
- `metrics`: append CSV/JSONL or tracker export for later consolidation.
- `results`: final machine-readable summary and human-readable short report.
- `tmux`: named session and reattach/capture commands documented in the generated launcher or output.

## Low-Token Monitoring Contract

Design the repo so Codex can monitor with one or two cheap commands:

```bash
cat /path/to/run_dir/status.json
tail -n 80 /path/to/run_dir/train.log
```

The status file should be the primary polling surface. Include enough information to decide whether to continue, inspect logs, restart, or summarize.

Recommended fields:

```json
{
  "run_id": "experiment-name-20260528-120000",
  "state": "running",
  "pid": 12345,
  "step": 1000,
  "epoch": 1,
  "metrics": {"loss": 1.23},
  "last_checkpoint": "checkpoints/step-1000",
  "started_at": "2026-05-28T12:00:00Z",
  "updated_at": "2026-05-28T12:30:00Z",
  "last_error": null
}
```

## References

- Read `references/patterns.md` when implementing concrete launcher, status, checkpoint, watchdog, or result-summary code.
