---
name: cluster-compute
description: "Run GPU or CPU experiments on remote machines through SSH and tmux. Reuse code, environments, and datasets while keeping development in the main project checkout."
---

# Remote compute for experiments

Use SSH and tmux under the user's account; no administrator access or background
scheduling service is required.

## 1. Read or establish the project setup

Read the personal host inventory at `~/.config/cluster-compute/hosts.md`, or its
location recorded by the project. It holds SSH aliases, hardware, usable storage,
shared mounts, preferred/fallback roles, and last verification. Discover aliases
from SSH config; ask about allowed hosts/preferences only when unknown. Hardware
observations aren't live availability. Keep host facts here, not copied into every
project. When working from another submission machine, locate this inventory or
copy it with the user identifying which copy is authoritative.

During first project setup, create these files from the linked templates, or
adapt existing equivalents:

| File | Purpose |
|---|---|
| [docs/compute.md](assets/compute.md) | Usage guide, inventory locations, and project-specific overrides |
| [.compute/resources.yaml](assets/resources.yaml) | Project ID, actual host paths, reusable resources, versions, and verification |
| [.compute/runs/<run-id>.json](assets/run.json) | One consistent record per attempt, also stored with remote outputs |

The development checkout owns the project records. Keep procedures in the guide
and paths/identities in the resource inventory. Update after setup, runs,
transfers, or cleanup; verify paths and reconcile stale records before creating
replacements. Mark planned/incomplete resources separately from verified ones.
Keep credentials out of these files.

On each execution host, maintain `~/.local/state/cluster-compute/projects.md` as
a small index of project IDs, their authoritative inventories and local roots,
plus shared asset/cache locations and ownership. Consult it for cross-project
reuse; it is a set of pointers, not another copy of every run record.

## 2. Choose available compute

Identify the experiment's GPU count, memory per GPU, CPU/RAM needs, dependencies,
and any compute budget. Check candidate hosts over SSH: GPU processes and memory
with `nvidia-smi`, CPU/RAM, disk space, and required storage mounts.

Choose compatible capacity using the user's preferences and the hosts'
allocation rules. Low GPU utilization alone doesn't mean a device is available.
Keep multi-GPU jobs on one host unless cross-host execution is intended. If
nothing fits, report that rather than silently changing experiment settings.
Fallback selects where a job starts; moving an active job requires supported
checkpoint/resume behavior. Preserve the experiment plan's model/settings rules.

## 3. Reuse and stage

Keep development in the main checkout. Use a stable project directory on each
execution host. Register the root before staging anything; adopt suitable
existing paths rather than duplicating or moving them just to match a convention.
For new roots use this layout, creating directories only when needed:

```text
<work-root>/projects/<project-id>/
  source/<source-id>/     fixed source copies, reused by multiple runs
  envs/<environment-id>/ reusable host-local environments
  runs/<run-id>/         command, run.json, logs, and local outputs
  scratch/<run-id>/      disposable temporary files
```

Keep datasets/weights in registered shared locations or local caches outside
individual run directories. Record their canonical location and any replicas.

- **Code:** Stage required source with Git or incremental `rsync`, including
  intended uncommitted changes. Exclude environments, caches, old results, and
  separately managed large assets. Match copies using the commit plus a content
  manifest/hash of included changes and pinned upstream code. Reuse matching
  source IDs; transfer only differences into a new version when needed. Never
  sync changes into code used by a running job.
- **Environment:** Reuse a compatible host-local environment. Create missing
  environments from locked dependency files where available; record Python/runtime
  versions and the setup command. Match the dependency-file hash, Python version,
  install options, and relevant compiled/runtime requirements before reuse.
  Include source identity when packages installed into the environment depend on
  that source. Code-only changes otherwise reuse dependencies. Share package caches
  across projects on each host. Don't copy virtual environments between hosts or
  change dependencies during active runs. Incomplete setup isn't reusable yet.
- **Data and weights:** Use verified shared storage or stage the required version
  once. Record local copies and reuse them across runs.

Check imports and run a small smoke test on a new host/environment before a long
run. Update the project notes with prepared resources.

## 4. Launch in tmux

Give each run a unique directory and named tmux session. Set its working
directory, environment, GPU assignment, and outputs explicitly. Fill the run
record with the host/session, command, source/environment IDs, inputs/config,
resources, timestamps, logs, exit status, and result location. Mirror it into
the remote run directory so another session can recover it; update the central
copy from remote execution evidence. Use a new attempt ID for retries.

Recheck capacity before launch. Coordinate concurrent submissions of your own
jobs across projects; this cannot reserve GPUs against other users. Independent
cases can run in parallel or as a finite batch inside tmux. Bound runtime and
concurrency against the remaining budget, including active reservations, failed
attempts, and retries. Count GPU-hours as allocated GPU count times holding hours
across all hosts.

Confirm the process started. Return the host, session, logs, and output paths.
tmux survives normal SSH disconnects, not reboots; it doesn't schedule jobs
later when capacity frees up.

## 5. Monitor and retrieve

Inspect logs and exit status. Lost SSH contact means unknown status: check the
original run before retrying. When cancelling, verify its child processes stop.
Resume only when code, inputs, configuration, and checkpoint are compatible;
otherwise record a fresh attempt. Checkpoint long jobs to durable storage when
supported.

Read outputs from shared storage or incrementally copy required results back.
Verify receipt and update the project notes. Keep logs and run metadata.
Record compute completion separately from successful result transfer.
Reuse staged resources next time; remove only known disposable copies. Check
other projects' references before removing shared resources, and preserve active
dependencies and authoritative results.
