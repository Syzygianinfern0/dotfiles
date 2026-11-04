# Project compute guide

## Where to look

- Personal host inventory: `~/.config/cluster-compute/hosts.md` on the submission
  machine. Record its authoritative machine/path here if different.
- Project resources: `.compute/resources.yaml` in the main development checkout.
- Runs: `.compute/runs/<run-id>.json`, mirrored into each remote run directory.
- Host project index: `~/.local/state/cluster-compute/projects.md` on each worker.

## Project choices

During setup, document only project-specific placement overrides, the experiment
plan/budget, and how to select the project's environment. Keep actual paths and
resource identities in the resource inventory rather than duplicating them here.

## Working commands

During setup, record the actual commands for staging, starting the experiment,
reading logs/status, cancelling a run, and retrieving results. Use the paths and
identities in the inventories. Record how to verify setup or resume a checkpoint.

## Reuse and cleanup

Consult the inventories before creating resources. Reuse matching source and
environments; stage missing dataset/model versions once. Keep run outputs and
scratch separate from reusable inputs. Update records when resources change.
Before removing copies, check active/retained runs and references from other
projects, and verify that canonical results have been retained.
