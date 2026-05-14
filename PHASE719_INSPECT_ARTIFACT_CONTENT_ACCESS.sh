
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT ARTIFACT CONTENT ACCESS ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_ARTIFACT_CONTENT_ACCESS_INSPECTION.txt"

{

  echo "PHASE 719 ARTIFACT CONTENT ACCESS INSPECTION"

  echo ""

  echo "Timestamp:"

  date

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "HEAD:"

  git log --oneline --decorate -5

  echo ""

  echo "Runtime health:"

  curl -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo ""

  echo "Task artifact sample:"

  curl -s --max-time 10 http://localhost:3000/api/tasks | python3 - << 'PY' || true

import json, sys

try:

    data = json.load(sys.stdin)

    for task in data.get("tasks", []):

        artifact = task.get("artifact") or (task.get("artifacts") or [None])[0]

        if artifact:

            print(json.dumps({

                "task_id": task.get("task_id"),

                "title": task.get("title"),

                "artifact": artifact,

                "outcome_preview": task.get("outcome_preview"),

                "explanation_preview": task.get("explanation_preview"),

            }, indent=2))

            break

except Exception as e:

    print("artifact sample parse failed:", e)

PY

  echo ""

  echo "Container artifact directory:"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'ls -la /app/data/artifacts 2>/dev/null | head -40 || true'

  echo ""

  echo "Container artifact file preview:"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'f="$(ls -1 /app/data/artifacts/*.md 2>/dev/null | head -n 1)"; if [ -n "$f" ]; then echo "$f"; sed -n "1,120p" "$f"; else echo "No markdown artifact found"; fi' || true

  echo ""

  echo "Static/public artifact access probes:"

  curl -i -s --max-time 10 http://localhost:3000/data/artifacts/ | head -n 40 || true

  echo ""

  curl -i -s --max-time 10 http://localhost:3000/artifacts/ | head -n 40 || true

  echo ""

  echo "Existing artifact routes/files:"

  grep -R -nE "api/artifacts|events/artifacts|express.static.*artifacts|/app/data/artifacts|MB_ARTIFACT_DIR" server public Dockerfile* docker-compose* 2>/dev/null || true

  echo ""

  echo "Preview modal markers:"

  grep -nE "phase719-preview-modal|phase719OpenPreviewModal|data-artifact-path|data-artifact-outcome|data-artifact-explanation" public/js/phase530_visible_panels_bridge.js || true

} | tee "$OUT"

cat > checkpoints/PHASE719_ARTIFACT_CONTENT_ACCESS_INSPECTION_NOTE.md << 'NOTE'

PHASE 719 ARTIFACT CONTENT ACCESS INSPECTION NOTE

Purpose:

- Determine whether the frontend can already read artifact file contents.

- Preserve current frontend-only rendered preview goal unless inspection proves a read-only content route is required.

Decision rule:

- If artifact content is not reachable by the browser, do not guess.

- Prefer the smallest read-only content route or static mount only after confirming no existing route serves /app/data/artifacts.

- Do not mutate retry, execution, worker, DB schema, or task lifecycle contracts.

NOTE

git add PHASE719_INSPECT_ARTIFACT_CONTENT_ACCESS.sh

git add checkpoints/PHASE719_ARTIFACT_CONTENT_ACCESS_INSPECTION.txt

git add checkpoints/PHASE719_ARTIFACT_CONTENT_ACCESS_INSPECTION_NOTE.md

git commit -m "Phase 719: inspect artifact content access path"

git push origin "$BRANCH"

echo "===== ARTIFACT CONTENT ACCESS INSPECTION COMPLETE ====="

