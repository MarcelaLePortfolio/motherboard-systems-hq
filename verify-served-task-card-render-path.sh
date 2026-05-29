
#!/usr/bin/env bash

set -euo pipefail

TS="$(date +%Y%m%d_%H%M%S)"

REPORT="served-task-card-render-path-${TS}.md"

API_PROBE="api-tasks-served-render-path-${TS}.json"

SERVED_JS="served-phase530-visible-panels-bridge-${TS}.js"

curl -s 'http://localhost:8080/api/tasks?limit=50' > "$API_PROBE"

curl -s 'http://localhost:8080/js/phase530_visible_panels_bridge.js?v=task-card-controls-visible-smoke' > "$SERVED_JS"

python3 - "$REPORT" "$API_PROBE" "$SERVED_JS" << 'PY'

import json

import re

import sys

from pathlib import Path

report = Path(sys.argv[1])

api_probe = Path(sys.argv[2])

served_js = Path(sys.argv[3])

data = json.loads(api_probe.read_text(encoding="utf-8"))

tasks = data.get("tasks", [])

target = next((t for t in tasks if t.get("task_id") == "task-card-controls-visible-smoke"), None)

js = served_js.read_text(encoding="utf-8", errors="ignore")

markers = {

    "Preview marker": "data-phase719-preview-artifact",

    "Inspect trace marker": "data-phase717-inspect-trace",

    "Inspect logs marker": "data-phase717-inspect-logs",

    "renderRecent marker": "function renderRecent(tasks)",

    "taskRows marker": "function taskRows(tasks)",

    "artifactRaw payload support": "t.payload && t.payload.artifact",

    "trace payload support": "t.payload && t.payload.trace",

}

def nested_has(obj, names):

    payload = obj.get("payload") if isinstance(obj.get("payload"), dict) else {}

    metadata = obj.get("metadata") if isinstance(obj.get("metadata"), dict) else {}

    return any(obj.get(n) or payload.get(n) or metadata.get(n) for n in names)

artifact_present = bool(target and nested_has(target, ["artifact", "artifacts"]))

trace_present = bool(target and nested_has(target, ["trace", "status_trace", "statusTrace"]))

logs_present = bool(target and nested_has(target, ["logs", "log", "execution_logs", "executionLogs"]))

expected_preview = artifact_present

expected_trace = trace_present

expected_logs = True

with report.open("w", encoding="utf-8") as out:

    out.write("# Served Task Card Render Path Verification\n\n")

    out.write("Endpoint: http://localhost:8080\n\n")

    out.write("## Served JS Marker Check\n\n")

    for label, marker in markers.items():

        out.write(f"- {label}: {'FOUND' if marker in js else 'MISSING'}\n")

    out.write("\n## API Target Row Check\n\n")

    if target:

        out.write("Target row: FOUND\n")

        out.write(f"task_id: {target.get('task_id')}\n")

        out.write(f"status: {target.get('status')}\n")

        out.write(f"artifact payload: {'FOUND' if artifact_present else 'MISSING'}\n")

        out.write(f"trace payload: {'FOUND' if trace_present else 'MISSING'}\n")

        out.write(f"logs payload: {'FOUND' if logs_present else 'MISSING'}\n")

    else:

        out.write("Target row: MISSING\n")

    out.write("\n## Expected Control Evaluation\n\n")

    out.write(f"Preview expected: {'YES' if expected_preview else 'NO'}\n")

    out.write(f"Inspect trace expected: {'YES' if expected_trace else 'NO'}\n")

    out.write(f"Inspect logs expected: {'YES' if expected_logs else 'NO'}\n")

    out.write("\n## Diagnosis\n\n")

    if all(marker in js for marker in markers.values()) and target and expected_preview and expected_trace and expected_logs:

        out.write("Served JS and API data both satisfy the control-rendering contract.\n")

        out.write("If the controls are not visible in the browser, the remaining issue is live DOM rendering, browser cache, filtering, or a different mounted task list surface.\n")

    else:

        out.write("At least one served JS marker or API payload requirement is missing.\n")

    out.write("\n## Target Row Sample\n\n")

    out.write(json.dumps(target, indent=2)[:6000] if target else "null")

    out.write("\n")

print(report.read_text(encoding="utf-8"))

PY

git add "$REPORT" "$API_PROBE" "$SERVED_JS" verify-served-task-card-render-path.sh

git commit -m "Verify served task card render path"

git push

