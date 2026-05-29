
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

REPORT="task-card-controls-runtime-probe-${STAMP}.md"

API_PROBE="api-tasks-controls-runtime-probe-${STAMP}.json"

{

  echo "# Task Card Controls Runtime Probe"

  echo

  echo "Repo: $(git rev-parse --show-toplevel)"

  echo "Branch: $(git branch --show-current)"

  echo "HEAD: $(git rev-parse HEAD)"

  echo

  echo "## Runtime Start"

  echo

} > "$REPORT"

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then

  docker compose up -d >> "$REPORT" 2>&1 || true

else

  echo "Docker compose unavailable." >> "$REPORT"

fi

{

  echo

  echo "## Runtime Probe"

  echo

} >> "$REPORT"

for i in 1 2 3 4 5 6 7 8 9 10; do

  if curl -fsS http://localhost:3000/api/tasks -o "$API_PROBE"; then

    break

  fi

  sleep 3

done

if [ ! -s "$API_PROBE" ]; then

  printf '{"api_probe":"unavailable","reason":"localhost:3000/api/tasks did not respond after runtime start attempt"}\n' > "$API_PROBE"

fi

python3 - "$API_PROBE" "$REPORT" << 'PY'

import json

import sys

from pathlib import Path

api_path = Path(sys.argv[1])

report = Path(sys.argv[2])

try:

    data = json.loads(api_path.read_text(encoding="utf-8", errors="ignore"))

except Exception as exc:

    data = {"parse_error": str(exc), "raw_preview": api_path.read_text(encoding="utf-8", errors="ignore")[:1000]}

tasks = data.get("tasks") if isinstance(data, dict) else None

if not isinstance(tasks, list):

    tasks = []

def has_any(obj, names):

    if not isinstance(obj, dict):

        return False

    for name in names:

        if obj.get(name):

            return True

    payload = obj.get("payload") if isinstance(obj.get("payload"), dict) else {}

    metadata = obj.get("metadata") if isinstance(obj.get("metadata"), dict) else {}

    return any(payload.get(name) or metadata.get(name) for name in names)

artifact_count = sum(1 for t in tasks if has_any(t, ["artifact", "artifacts"]))

trace_count = sum(1 for t in tasks if has_any(t, ["trace", "status_trace", "statusTrace"]))

log_count = sum(1 for t in tasks if has_any(t, ["logs", "log", "execution_logs", "executionLogs"]))

with report.open("a", encoding="utf-8") as out:

    out.write(f"Task count: {len(tasks)}\n")

    out.write(f"Rows with artifact payloads: {artifact_count}\n")

    out.write(f"Rows with trace payloads: {trace_count}\n")

    out.write(f"Rows with log payloads: {log_count}\n\n")

    out.write("## Control Visibility Diagnosis\n\n")

    out.write("- Preview pill requires artifact/artifacts payload data.\n")

    out.write("- Inspect trace requires trace/status_trace/statusTrace payload data.\n")

    out.write("- Inspect logs requires log/logs/execution_logs payload data.\n\n")

    out.write("## API Shape Sample\n\n")

    out.write(json.dumps(data, indent=2)[:6000])

    out.write("\n")

PY

cat "$REPORT"

git add "$REPORT" "$API_PROBE" probe-task-card-controls-after-runtime-start.sh

git commit -m "Probe task card controls runtime payloads"

git push

