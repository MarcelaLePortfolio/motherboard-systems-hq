
#!/usr/bin/env bash

set -euo pipefail

REPORT="TASK_CARD_STATUS_TRACE_PREVIEW_FALLBACKS.txt"

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

replacements = [

    (

'''      const artifactRaw = t.artifact || (Array.isArray(t.artifacts) ? t.artifacts[0] : null) || null;''',

'''      const artifactRaw = t.artifact || (Array.isArray(t.artifacts) ? t.artifacts[0] : null) || (t.payload && t.payload.artifact) || (t.payload && Array.isArray(t.payload.artifacts) ? t.payload.artifacts[0] : null) || (t.metadata && t.metadata.artifact) || (t.metadata && Array.isArray(t.metadata.artifacts) ? t.metadata.artifacts[0] : null) || null;'''

    ),

    (

'''      const triageLabel = triageStatusRaw === "completed" ? "triage: completed" : "";''',

'''      const triageLabel = status ? `status: ${status}` : "";'''

    ),

    (

'''      const guidance = t.guidance || {};

      const trace = guidance.communicationResult && guidance.communicationResult.systemTrace

        ? guidance.communicationResult.systemTrace.content

        : null;

      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";''',

'''      const guidance = t.guidance || (t.payload && t.payload.guidance) || (t.metadata && t.metadata.guidance) || {};

      const trace = guidance.communicationResult && guidance.communicationResult.systemTrace

        ? guidance.communicationResult.systemTrace.content

        : ((t.payload && t.payload.trace) || (t.metadata && t.metadata.trace) || null);

      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";'''

    ),

]

for old, new in replacements:

    if old not in text:

        raise SystemExit("target renderer block not found; refusing patch")

    text = text.replace(old, new, 1)

path.write_text(text, encoding="utf-8")

PY

{

  echo "===== TASK CARD STATUS TRACE PREVIEW FALLBACKS ====="

  date

  echo

  git diff -- public/js/phase530_visible_panels_bridge.js

} | tee "$REPORT"

docker compose build dashboard

docker compose up -d dashboard

sleep 2

echo "===== VERIFY /api/tasks =====" | tee -a "$REPORT"

curl -sS "http://localhost:8080/api/tasks?limit=5" | tee -a "$REPORT" | python3 -m json.tool

echo "===== VERIFY HEALTH =====" | tee -a "$REPORT"

curl -i http://localhost:8080/api/tasks/health | tee -a "$REPORT"

git add public/js/phase530_visible_panels_bridge.js restore-task-card-status-trace-preview-fallbacks.sh "$REPORT"

git commit -m "Restore task card status trace preview fallbacks"

git push

