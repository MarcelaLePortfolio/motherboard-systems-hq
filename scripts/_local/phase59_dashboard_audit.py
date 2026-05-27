#!/usr/bin/env python3
from __future__ import annotations

import os
import subprocess
from collections import defaultdict

TARGET_STRINGS = [
    "Project Visual Output",
    "Critical Ops Alerts",
    "System Reflections",
    "Agent Pool",
    "Matilda Chat Console",
    "Task Delegation",
    "Recent Tasks",
    "Task Activity Over Time",
    "Atlas Subsystem Status",
    "policy.probe.run",
    "Probe Event Stream",
]

ALLOWED_EXTS = {
    ".ts", ".tsx", ".js", ".jsx", ".css", ".scss", ".sass", ".less",
    ".html", ".md", ".json"
}

EXCLUDE_PARTS = {
    "node_modules/",
    ".next/",
    "dist/",
    "build/",
    "coverage/",
    ".git/",
}


def tracked_files() -> list[str]:
    out = subprocess.check_output(
        ["git", "ls-files"],
        text=True,
    )
    return [line.strip() for line in out.splitlines() if line.strip()]


def is_allowed(path: str) -> bool:
    if any(part in path for part in EXCLUDE_PARTS):
        return False
    _, ext = os.path.splitext(path)
    return ext.lower() in ALLOWED_EXTS


def load_text(path: str) -> str | None:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    except Exception:
        return None


def main() -> int:
    files = [p for p in tracked_files() if is_allowed(p)]
    hits_by_file: dict[str, list[str]] = defaultdict(list)

    for path in files:
        text = load_text(path)
        if not text:
            continue
        for needle in TARGET_STRINGS:
            if needle in text:
                hits_by_file[path].append(needle)

    print("=== Phase 59 dashboard audit ===")
    if not hits_by_file:
        print("No candidate files found.")
        return 0

    ranked = sorted(
        hits_by_file.items(),
        key=lambda item: (-len(item[1]), item[0]),
    )

    for path, hits in ranked:
        print(f"{path}")
        for hit in hits:
            print(f"  - {hit}")
        print()

    top_paths = [path for path, _ in ranked[:10]]
    print("=== Recommended review order ===")
    for path in top_paths:
        print(path)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
