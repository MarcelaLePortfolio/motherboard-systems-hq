
#!/usr/bin/env bash

set -euo pipefail

OUT_DIR="phase719_triage_inspection"

OUT_FILE="$OUT_DIR/task_triage_fields.txt"

TMP_FILE="$(mktemp)"

mkdir -p "$OUT_DIR"

echo "===== PHASE 719 TRIAGE FIELD INSPECTION ====="

echo ""

curl -fsS http://localhost:3000/api/tasks > "$TMP_FILE"

python3 - "$TMP_FILE" "$OUT_FILE" <<'PY'

import json

import sys

from pathlib import Path

src = Path(sys.argv[1])

out = Path(sys.argv[2])

data = json.loads(src.read_text())

if isinstance(data, dict):

    tasks = data.get("tasks") or data.get("items") or data.get("data") or []

elif isinstance(data, list):

    tasks = data

else:

    tasks = []

fields = [

    "id",

    "task_id",

    "title",

    "status",

    "error",

    "failure_reason",

    "result",

    "events",

    "execution_meta",

    "explanation_preview",

    "created_at",

    "updated_at",

    "completed_at",

]

lines = []

lines.append(f"task_count: {len(tasks)}")

lines.append("")

for index, task in enumerate(tasks[:8], 1):

    lines.append(f"--- TASK {index} ---")

    if not isinstance(task, dict):

        lines.append(f"non_dict_task: {task!r}")

        lines.append("")

        continue

    for field in fields:

        if field in task:

            value = task.get(field)

            rendered = json.dumps(value, ensure_ascii=False, default=str)

            if len(rendered) > 500:

                rendered = rendered[:500] + "...<truncated>"

            lines.append(f"{field}: {rendered}")

    lines.append("")

out.write_text("\n".join(lines))

print(f"inspection_file: {out}")

print(f"task_count: {len(tasks)}")

print("top_statuses:")

status_counts = {}

for task in tasks:

    if isinstance(task, dict):

        status = str(task.get("status", "missing"))

        status_counts[status] = status_counts.get(status, 0) + 1

for status, count in sorted(status_counts.items()):

    print(f"- {status}: {count}")

PY

rm -f "$TMP_FILE"

echo ""

echo "Saved detailed inspection to: $OUT_FILE"

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_TRIAGE_FIELD_INSPECTION.sh "$OUT_DIR"

git commit -m "Phase 719: inspect triage fields"

git push origin dev

