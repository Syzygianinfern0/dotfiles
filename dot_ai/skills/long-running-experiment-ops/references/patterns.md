# Long-Running Experiment Patterns

## Atomic Status Writes

For Python code, prefer a tiny helper near the training entrypoint:

```python
import json
import os
import time
from pathlib import Path


def write_status(run_dir, **fields):
    path = Path(run_dir) / "status.json"
    tmp = path.with_suffix(".json.tmp")
    payload = {"updated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), **fields}
    tmp.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")
    os.replace(tmp, path)
```

Write status at startup, after each eval/checkpoint, on graceful shutdown, and inside the top-level exception handler.

## Top-Level Failure Capture

Wrap the training main only at the outer boundary:

```python
try:
    main()
except Exception as exc:
    write_status(run_dir, state="failed", last_error=repr(exc))
    raise
```

Do not catch exceptions deep in the training loop unless the code can recover correctly.

## Shell Launcher Shape

Use a launcher that snapshots the command and environment before executing:

```bash
#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${RUN_ID:-exp-$(date -u +%Y%m%d-%H%M%S)}"
RUN_DIR="${RUN_DIR:-runs/$RUN_ID}"
mkdir -p "$RUN_DIR"

printf '%q ' "$0" "$@" > "$RUN_DIR/command.txt"
env | sort > "$RUN_DIR/env.txt"

exec "$@" 2>&1 | tee -a "$RUN_DIR/train.log"
```

If the pipeline exit status matters under `tee`, enable `set -o pipefail`.

## tmux Wrapper Shape

```bash
SESSION="${SESSION:-$RUN_ID}"
tmux new-session -d -s "$SESSION" "bash scripts/run_train.sh ..."
echo "tmux capture-pane -t $SESSION -p -S -120"
echo "tmux attach -t $SESSION"
```

Prefer writing logs in the training process itself; tmux scrollback is a convenience, not the source of truth.

## Watchdog Shape

Only add automatic restarts when requested or clearly expected. Cap attempts:

```bash
MAX_RESTARTS="${MAX_RESTARTS:-3}"
attempt=0
while (( attempt <= MAX_RESTARTS )); do
  attempt=$((attempt + 1))
  echo "attempt=$attempt" | tee -a "$RUN_DIR/watchdog.log"
  if bash scripts/run_train.sh --resume latest; then
    exit 0
  fi
  sleep "${RESTART_DELAY_SECONDS:-60}"
done
exit 1
```

Persist each crash log separately, for example `crash-attempt-1.log`, so repeated failures are diagnosable.

## Result Summary

At successful completion, write `summary.json`:

```json
{
  "run_id": "exp-20260528-120000",
  "state": "completed",
  "best_metric": {"name": "eval_loss", "value": 0.91, "step": 5000},
  "final_metrics": {"train_loss": 0.88, "eval_loss": 0.93},
  "last_checkpoint": "checkpoints/step-5000",
  "duration_seconds": 12345
}
```

If a run fails, still write `summary.json` with `state: "failed"` and `last_error`.
