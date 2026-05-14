
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT ARTIFACT FILE LOCATION MISMATCH ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_ARTIFACT_FILE_LOCATION_MISMATCH.txt"

TASK_ID="t_d1efc418-5049-401c-89fe-19eaceb8f784"

{

  echo "PHASE 719 ARTIFACT FILE LOCATION MISMATCH"

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

  echo "Task API artifact payload:"

  curl -s --max-time 10 http://localhost:3000/api/tasks | grep -o '"artifact":{[^}]*}' | head -n 3 || true

  echo ""

  echo "Dashboard /app/data:"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'find /app/data -maxdepth 4 -type f -print 2>/dev/null | sort | head -80' || true

  echo ""

  echo "Worker /app/data:"

  docker exec motherboard_systems_hq-worker-1 sh -lc 'find /app/data -maxdepth 4 -type f -print 2>/dev/null | sort | head -80' || true

  echo ""

  echo "Docker compose volumes:"

  docker compose config | sed -n '/services:/,/networks:/p' | grep -nE 'dashboard:|worker:|volumes:|/app/data|guidance_data|source:|target:' || true

  echo ""

  echo "Preview route test:"

  curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 80 || true

} | tee "$OUT"

cat > checkpoints/PHASE719_ARTIFACT_FILE_LOCATION_MISMATCH_NOTE.md << 'NOTE'

PHASE 719 ARTIFACT FILE LOCATION MISMATCH NOTE

Current result:

- The preview route is mounted and DB access works.

- It returns artifact_file_missing, meaning metadata exists but dashboard container cannot see the artifact file at the recorded path.

Next decision:

- If worker has /app/data/artifacts but dashboard does not, mount the same guidance_data volume into worker OR use the correct shared volume path.

- Do not patch preview rendering until file visibility is resolved.

- Avoid broad static mounts.

NOTE

git add PHASE719_INSPECT_ARTIFACT_FILE_LOCATION_MISMATCH.sh

git add "$OUT"

git add checkpoints/PHASE719_ARTIFACT_FILE_LOCATION_MISMATCH_NOTE.md

git commit -m "Phase 719: inspect artifact file location mismatch"

git push origin "$BRANCH"

echo "===== ARTIFACT FILE LOCATION INSPECTION COMPLETE ====="

