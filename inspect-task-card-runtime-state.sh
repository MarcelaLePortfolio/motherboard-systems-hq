
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

REPORT="task-card-runtime-state-${STAMP}.md"

API_PROBE="api-tasks-runtime-probe-${STAMP}.json"

python3 - "$REPORT" << 'PY'

from pathlib import Path

import subprocess

import sys

report = Path(sys.argv[1])

root = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())

bridge = root / "public/js/phase530_visible_panels_bridge.js"

tokens = [

    "data-phase717-inspect-trace",

    "data-phase717-inspect-logs",

    "data-phase719-preview-artifact",

    "phase719-preview-modal",

    "renderRecent",

    "traceJson",

    "logContent",

    "artifact",

]

with report.open("w", encoding="utf-8") as out:

    out.write("# Task Card Runtime State Inspection\n\n")

    out.write(f"Repo: {root}\n")

    out.write(f"Branch: {subprocess.check_output(['git', 'branch', '--show-current'], text=True).strip()}\n")

    out.write(f"HEAD: {subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()}\n\n")

    out.write("## Source Marker Verification\n\n")

    if not bridge.exists():

        out.write("MISSING: public/js/phase530_visible_panels_bridge.js\n\n")

    else:

        lines = bridge.read_text(encoding="utf-8", errors="ignore").splitlines()

        for token in tokens:

            matches = [(i + 1, line.strip()) for i, line in enumerate(lines) if token in line]

            if matches:

                out.write(f"### {token}\n")

                for line_no, line in matches[:12]:

                    out.write(f"{bridge.relative_to(root)}:{line_no}:{line[:500]}\n")

                if len(matches) > 12:

                    out.write("RESULT_LIMIT_REACHED\n")

                out.write("\n")

            else:

                out.write(f"### {token}\nNO_MATCHES\n\n")

PY

printf '{"api_probe":"not_run_or_unavailable","reason":"localhost:3000 unavailable or curl failed"}\n' > "$API_PROBE"

curl -sS http://localhost:3000/api/tasks -o "$API_PROBE" || true

{

  printf "\n## API Shape Probe\n\n"

  python3 -m json.tool "$API_PROBE" 2>/dev/null || cat "$API_PROBE" 2>/dev/null || true

} >> "$REPORT"

cat "$REPORT"

git add "$REPORT" "$API_PROBE" inspect-task-card-runtime-state.sh

git commit -m "Inspect task card runtime state"

git push

