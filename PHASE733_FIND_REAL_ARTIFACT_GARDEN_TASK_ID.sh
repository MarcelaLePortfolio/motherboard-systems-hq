
#!/bin/bash

set -euo pipefail

OUTPUT="PHASE733_RECENT_ARTIFACT_GARDEN_TASKS.json"

curl -s "http://localhost:3000/api/tasks" > "$OUTPUT"

echo ""

echo "=== Saved recent task payload ==="

echo "$OUTPUT"

echo ""

echo "=== Candidate Artifact Garden task ids ==="

python3 - << 'PY'

import json

from pathlib import Path

payload = json.loads(

    Path("PHASE733_RECENT_ARTIFACT_GARDEN_TASKS.json").read_text()

)

tasks = payload.get("tasks", payload if isinstance(payload, list) else [])

for task in tasks:

    text = " ".join(

        str(task.get(k, ""))

        for k in (

            "task_id",

            "id",

            "title",

            "summary",

            "status",

            "created_at",

            "updated_at",

        )

    )

    if (

        "Artifact Garden" in text

        or "artifact garden" in text

        or "Style Intent" in text

        or "style intent" in text

    ):

        print("task_id:", task.get("task_id") or task.get("id"))

        print("title:", task.get("title"))

        print("status:", task.get("status"))

        print("updated_at:", task.get("updated_at") or task.get("created_at"))

        print("---")

PY

echo ""

echo "Copy the REAL task_id above, then run:"

echo "./PHASE733_VERIFY_STYLE_INTENT_PAYLOAD.sh"

