#!/usr/bin/env python3
"""Inventory a repo for long-running experiment readiness signals."""

from __future__ import annotations

import argparse
import os
from pathlib import Path


SKIP_DIRS = {
    ".git",
    ".hg",
    ".svn",
    ".venv",
    "venv",
    "env",
    "__pycache__",
    ".mypy_cache",
    ".pytest_cache",
    "node_modules",
    "wandb",
    "runs",
    "outputs",
    "checkpoints",
}

TEXT_EXTENSIONS = {
    ".py",
    ".sh",
    ".bash",
    ".zsh",
    ".yaml",
    ".yml",
    ".json",
    ".toml",
    ".ini",
    ".cfg",
    ".md",
    ".txt",
}

SIGNALS = {
    "training_entrypoints": ["train", "finetune", "fine_tune", "fit", "trainer"],
    "checkpointing": ["checkpoint", "save_pretrained", "save_checkpoint", "torch.save", "resume_from_checkpoint"],
    "resume": ["resume", "load_checkpoint", "from_pretrained", "restore"],
    "logging": ["logging", "logger", "tensorboard", "wandb", "mlflow", "tee"],
    "status_artifacts": ["status.json", "summary.json", "metrics.jsonl", "metrics.csv"],
    "launchers": ["tmux", "nohup", "sbatch", "srun", "accelerate launch", "torchrun", "deepspeed"],
    "signal_handling": ["SIGTERM", "SIGINT", "signal.signal", "atexit"],
}


def iter_files(root: Path, max_files: int) -> list[Path]:
    files: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".tox")]
        for filename in filenames:
            path = Path(dirpath) / filename
            if path.suffix.lower() in TEXT_EXTENSIONS or os.access(path, os.X_OK):
                files.append(path)
                if len(files) >= max_files:
                    return files
    return files


def read_text(path: Path, max_bytes: int) -> str:
    try:
        data = path.read_bytes()[:max_bytes]
    except OSError:
        return ""
    return data.decode("utf-8", errors="ignore")


def find_matches(root: Path, files: list[Path], max_bytes: int) -> dict[str, list[str]]:
    matches = {name: [] for name in SIGNALS}
    for path in files:
        rel = path.relative_to(root)
        text = read_text(path, max_bytes)
        haystack = f"{rel}\n{text}".lower()
        for signal, needles in SIGNALS.items():
            if any(needle.lower() in haystack for needle in needles):
                matches[signal].append(str(rel))
    return matches


def print_section(name: str, values: list[str], limit: int) -> None:
    print(f"\n## {name}")
    if not values:
        print("- missing")
        return
    for value in values[:limit]:
        print(f"- {value}")
    if len(values) > limit:
        print(f"- ... {len(values) - limit} more")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", nargs="?", default=".", help="Repository path to inspect")
    parser.add_argument("--max-files", type=int, default=800)
    parser.add_argument("--max-bytes-per-file", type=int, default=200_000)
    parser.add_argument("--limit", type=int, default=12, help="Max matches to print per section")
    args = parser.parse_args()

    root = Path(args.repo).resolve()
    if not root.exists():
        parser.error(f"repo does not exist: {root}")

    files = iter_files(root, args.max_files)
    matches = find_matches(root, files, args.max_bytes_per_file)

    print(f"# Long-running readiness audit: {root}")
    print(f"\nScanned {len(files)} text-like files.")
    for signal in SIGNALS:
        print_section(signal, sorted(set(matches[signal])), args.limit)

    missing = [signal for signal, values in matches.items() if not values]
    print("\n## suggested next checks")
    if missing:
        for signal in missing:
            print(f"- Inspect or add support for {signal.replace('_', ' ')}.")
    else:
        print("- All readiness signal categories were found; inspect quality and integration next.")

    print("- Verify a smoke run creates logs, status, checkpoints/resume artifacts, and summary output.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
