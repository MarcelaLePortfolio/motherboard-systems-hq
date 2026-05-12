
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

OUT_DIR="phase719_lifecycle_delegation_inspection"

OUT_FILE="$OUT_DIR/task_payload_fields.txt"

TMP_FILE="$(mktemp)"

mkdir -p "$OUT_DIR"

echo "===== PHASE 719 LIFECYCLE + DELEGATION INSPECTION ====="

echo ""

echo "[1] Lifecycle pill render anchors"

grep -nE "lifecycle|triageLabel|executionStrategy|retryOf|targetTitle|title = esc|rawTitle|task_id|taskTitle|delegat|intent|prompt|request|description|summary|goal" "$TARGET" | head -100 || true

echo ""

echo "[2] Fetch task payload"

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

candidate_fields = [

    "id",

    "task_id",

    "title",

    "task_title",

    "label",

    "summary",

    "description",

    "goal",

    "intent",

    "request",

    "prompt",

    "input",

    "delegation",

    "delegation_text",

    "operator_request",

    "user_request",

    "message",

    "status",

    "strategy",

    "execution_mode",

    "retry_of_task_id",

    "explanation_preview",

    "outcome_preview",

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

    lines.append("available_keys:")

    lines.append(", ".join(sorted(task.keys())))

    lines.append("")

    lines.append("candidate_values:")

    for field in candidate_fields:

        if field in task:

            value = task.get(field)

            rendered = json.dumps(value, ensure_ascii=False, default=str)

            if len(rendered) > 350:

                rendered = rendered[:350] + "...<truncated>"

            lines.append(f"{field}: {rendered}")

    lines.append("")

out.write_text("\n".join(lines))

print(f"inspection_file: {out}")

print(f"task_count: {len(tasks)}")

PY

rm -f "$TMP_FILE"

echo ""

echo "[3] Payload field inspection preview"

sed -n '1,120p' "$OUT_FILE"

echo ""

echo "[4] Runtime check"

docker compose ps

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

echo "dashboard + /api/tasks: PASS"

echo ""

echo "[5] Repo status"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_LIFECYCLE_DELEGATION_INSPECTION.sh "$OUT_DIR"

git commit -m "Phase 719: inspect lifecycle pill and delegation fields"

git push origin dev

