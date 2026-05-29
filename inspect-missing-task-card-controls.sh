
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

REPORT="missing-task-card-controls-inspection-${STAMP}.md"

API_PROBE="api-tasks-probe-${STAMP}.json"

python3 - "$REPORT" << 'PY'

import os

import re

import sys

import subprocess

report = sys.argv[1]

root = subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip()

skip_dirs = {

    ".git",

    "node_modules",

    "backups",

    "_restore_test",

    "_dashboard_candidate_previews",

    "DASHBOARD_UI_RECOVERY_ANCHORS",

    ".next",

    "dist",

    "build",

    "coverage",

}

skip_exts = {

    ".bundle",

    ".tar.gz",

    ".gz",

    ".zip",

    ".png",

    ".jpg",

    ".jpeg",

    ".gif",

    ".webp",

    ".ico",

    ".pdf",

    ".map",

    ".log",

    ".db",

    ".sqlite",

}

patterns = [

    ("Inspect Trace", r"Inspect Trace|inspect trace|trace.*inspect|inspect.*trace|status trace|statusTrace|data-phase717-inspect-trace"),

    ("Inspect Logs", r"Inspect Logs|inspect logs|logs.*inspect|inspect.*logs|task logs|taskLogs|execution logs|executionLogs|data-phase717-inspect-logs"),

    ("Preview Pill / Preview Button", r"Preview|preview pill|previewPill|artifact-preview|phase719-preview-modal|data-phase719-preview-artifact"),

    ("Recent Task Card Rendering", r"Recent Tasks|recent tasks|recentTasks|task card|task-card|TaskCard|render.*task|task.*render|renderRecent"),

]

candidate_files = []

for dirpath, dirnames, filenames in os.walk(root):

    dirnames[:] = [d for d in dirnames if d not in skip_dirs]

    for name in filenames:

        path = os.path.join(dirpath, name)

        rel = os.path.relpath(path, root)

        if any(rel.endswith(ext) for ext in skip_exts):

            continue

        try:

            if os.path.getsize(path) > 1_000_000:

                continue

        except OSError:

            continue

        candidate_files.append(path)

with open(report, "w", encoding="utf-8") as out:

    out.write("# Missing Task Card Controls Inspection\n\n")

    out.write(f"Repo: {root}\n")

    out.write(f"Branch: {subprocess.check_output(['git', 'branch', '--show-current'], text=True).strip()}\n")

    out.write(f"HEAD: {subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()}\n")

    out.write(f"Candidate files scanned: {len(candidate_files)}\n\n")

    for title, pattern in patterns:

        rx = re.compile(pattern, re.IGNORECASE)

        out.write(f"## Search: {title}\n\n")

        found = 0

        for path in candidate_files:

            rel = os.path.relpath(path, root)

            try:

                with open(path, "r", encoding="utf-8", errors="ignore") as f:

                    for i, line in enumerate(f, 1):

                        if rx.search(line):

                            out.write(f"{rel}:{i}:{line.rstrip()[:500]}\n")

                            found += 1

                            if found >= 40:

                                break

            except Exception:

                pass

            if found >= 40:

                out.write("RESULT_LIMIT_REACHED\n")

                break

        if found == 0:

            out.write("NO_MATCHES\n")

        out.write("\n")

PY

printf '{"api_probe":"not_run_or_unavailable","reason":"localhost:3000 unavailable or curl failed"}\n' > "$API_PROBE"

curl -sS http://localhost:3000/api/tasks -o "$API_PROBE" || true

{

  printf "\n## API Shape Probe\n\n"

  python3 -m json.tool "$API_PROBE" 2>/dev/null || cat "$API_PROBE" 2>/dev/null || true

} >> "$REPORT"

cat "$REPORT"

git add "$REPORT" "$API_PROBE" inspect-missing-task-card-controls.sh

git commit -m "Bound missing task card controls inspection"

git push

