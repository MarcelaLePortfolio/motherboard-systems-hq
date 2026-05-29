
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

REPORT="task-card-controls-actual-port-probe-${STAMP}.md"

API_PROBE="api-tasks-actual-port-probe-${STAMP}.json"

curl -sS "http://localhost:8080/api/tasks?limit=50" -o "$API_PROBE" || printf '{"tasks":[],"error":"curl_failed"}\n' > "$API_PROBE"

python3 - "$API_PROBE" "$REPORT" << 'PY'

import json

import sys

from pathlib import Path

api_path = Path(sys.argv[1])

report = Path(sys.argv[2])

try:

    data = json.loads(api_path.read_text(encoding="utf-8", errors="ignore"))

except Exception as exc:

    data = {"tasks": [], "parse_error": str(exc)}

tasks = data.get("tasks")

if not isinstance(tasks, list):

    tasks = data if isinstance(data, list) else []

def nested_has(obj, names):

    if not isinstance(obj, dict):

        return False

    payload = obj.get("payload") if isinstance(obj.get("payload"), dict) else {}

    metadata = obj.get("metadata") if isinstance(obj.get("metadata"), dict) else {}

    return any(

        obj.get(name) or payload.get(name) or metadata.get(name)

        for name in names

    )

artifact_count = sum(1 for t in tasks if nested_has(t, ["artifact", "artifacts"]))

trace_count = sum(1 for t in tasks if nested_has(t, ["trace", "status_trace", "statusTrace"]))

log_count = sum(1 for t in tasks if nested_has(t, ["logs", "log", "execution_logs", "executionLogs"]))

with report.open("w", encoding="utf-8") as out:

    out.write("# Task Card Controls Actual Port Probe\n\n")

    out.write("Endpoint: http://localhost:8080/api/tasks?limit=50\n\n")

    out.write(f"Task count: {len(tasks)}\n")

    out.write(f"Rows with artifact payloads: {artifact_count}\n")

    out.write(f"Rows with trace payloads: {trace_count}\n")

    out.write(f"Rows with log payloads: {log_count}\n\n")

    out.write("## Diagnosis\n\n")

    out.write("- Preview pill appears only when a task row includes artifact/artifacts data.\n")

    out.write("- Inspect trace appears only when a task row includes trace/status_trace/statusTrace data.\n")

    out.write("- Inspect logs appears only when a task row includes log/logs/execution_logs data.\n\n")

    out.write("## API Sample\n\n")

    out.write(json.dumps(data, indent=2)[:8000])

    out.write("\n")

PY

cat "$REPORT"

git add "$REPORT" "$API_PROBE" probe-task-card-controls-on-actual-port.sh

git commit -m "Probe task card controls on actual dashboard port"

git push

