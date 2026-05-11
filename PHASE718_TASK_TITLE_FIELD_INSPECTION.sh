
#!/usr/bin/env bash

set -euo pipefail

TMP_FILE="$(mktemp)"

echo "===== PHASE 718 TASK TITLE FIELD INSPECTION ====="

echo ""

curl -fsS http://localhost:3000/api/tasks > "$TMP_FILE"

python3 - "$TMP_FILE" <<'PY'

import json

import sys

from pathlib import Path

path = Path(sys.argv[1])

raw = path.read_text().strip()

if not raw:

    raise SystemExit("No JSON returned from /api/tasks")

data = json.loads(raw)

if isinstance(data, dict):

    tasks = data.get("tasks") or data.get("items") or data.get("data") or []

elif isinstance(data, list):

    tasks = data

else:

    tasks = []

print(f"task_count: {len(tasks)}")

print()

for i, task in enumerate(tasks[:5], 1):

    print(f"--- TASK {i} ---")

    if not isinstance(task, dict):

        print(f"non_dict_task: {task!r}")

        print()

        continue

    for key in [

        "title",

        "task_title",

        "label",

        "summary",

        "description",

        "goal",

        "intent",

        "name",

        "id",

        "status",

        "strategy",

        "execution_strategy",

        "execution_mode",

        "retry_of_task_id",

    ]:

        if key in task:

            print(f"{key}: {task.get(key)}")

    print()

PY

rm -f "$TMP_FILE"

echo "===== INSPECTION COMPLETE ====="

git add PHASE718_TASK_TITLE_FIELD_INSPECTION.sh

git commit -m "Phase 718: inspect task title fields"

git push origin dev

