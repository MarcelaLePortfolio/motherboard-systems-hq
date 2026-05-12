
#!/usr/bin/env bash

set -euo pipefail

rm -f PHASE719_DISABLE_INLINE_RECENT_TASKS_RENDERER.sh

rm -rf phase719_visible_details_trace

python3 - <<'PY'

from pathlib import Path

targets = [

    Path("public/index.html"),

    Path("public/dashboard.html"),

]

marker = "PHASE719_INLINE_RECENT_TASKS_METADATA_DISABLED"

for path in targets:

    if not path.exists():

        continue

    lines = path.read_text().splitlines()

    if any(marker in line for line in lines):

        print(f"already patched: {path}")

        continue

    start = None

    end = None

    for i, line in enumerate(lines):

        if "meta.innerHTML" in line:

            nearby = "\n".join(lines[i:i+5])

            if '"Status: " + summary.status' in nearby and '"Updated: " + summary.updated' in nearby:

                start = i

                break

    if start is None:

        raise SystemExit(f"Could not locate inline task metadata block in {path}")

    for j in range(start, min(start + 6, len(lines))):

        if '"Updated: " + summary.updated' in lines[j]:

            end = j

            break

    if end is None:

        raise SystemExit(f"Could not locate inline task metadata block end in {path}")

    indent = lines[start].split("meta.innerHTML")[0]

    replacement = [

        f"{indent}// {marker}",

        f"{indent}// Inline metadata suppressed; lifecycle cards are rendered by phase530_visible_panels_bridge.js.",

        f'{indent}meta.innerHTML = "";',

    ]

    lines[start:end + 1] = replacement

    path.write_text("\n".join(lines) + "\n")

    print(f"patched: {path}")

PY

grep -RIn "PHASE719_INLINE_RECENT_TASKS_METADATA_DISABLED" public/index.html public/dashboard.html

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

open "http://localhost:3000"

git add -A

git commit -m "Phase 719: disable inline recent task metadata"

git push origin dev

