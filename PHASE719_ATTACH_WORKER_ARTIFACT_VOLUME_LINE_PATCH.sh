
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: ATTACH WORKER ARTIFACT VOLUME LINE PATCH ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="docker-compose.yml"

OUT="checkpoints/PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_LINE_PATCH_VERIFY.txt"

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_PRE_WORKER_VOLUME_LINE_PATCH.yml

python3 - << 'PY'

from pathlib import Path

path = Path("docker-compose.yml")

lines = path.read_text().splitlines()

if not any(line.strip() == "worker_artifacts:" for line in lines):

    lines.append("  worker_artifacts:")

if not any("worker_artifacts:/app/data/artifacts:ro" in line for line in lines):

    for i, line in enumerate(lines):

        if line.strip() == "- guidance_data:/app/data":

            lines.insert(i + 1, "      - worker_artifacts:/app/data/artifacts:ro")

            break

    else:

        raise SystemExit("dashboard guidance_data volume marker not found")

if not any("worker_artifacts:/app/data/artifacts" in line and ":ro" not in line for line in lines):

    worker_start = None

    for i, line in enumerate(lines):

        if line == "  worker:":

            worker_start = i

            break

    if worker_start is None:

        raise SystemExit("worker service not found")

    worker_end = len(lines)

    for i in range(worker_start + 1, len(lines)):

        if lines[i].startswith("  ") and not lines[i].startswith("    ") and lines[i].strip():

            worker_end = i

            break

    insert_at = None

    for i in range(worker_start + 1, worker_end):

        if lines[i].strip() == "environment:":

            insert_at = i

            break

    if insert_at is None:

        raise SystemExit("worker environment marker not found")

    lines.insert(insert_at, "      - worker_artifacts:/app/data/artifacts")

    lines.insert(insert_at, "    volumes:")

path.write_text("\n".join(lines) + "\n")

PY

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_POST_WORKER_VOLUME_LINE_PATCH.yml

docker compose config > checkpoints/PHASE719_DOCKER_COMPOSE_WORKER_VOLUME_LINE_PATCH_CONFIG.txt

docker compose up -d --build worker dashboard

sleep 6

cat > /tmp/phase719_worker_volume_line_patch_body.json << 'JSON'

{"title":"Phase 719 worker shared artifact volume validation after line patch","agent":"cade","source":"phase719-worker-volume-line-patch"}

JSON

CREATE_RESPONSE="$(curl -sS --max-time 15 -X POST 'http://localhost:3000/api/tasks/create' -H 'Content-Type: application/json' --data-binary @/tmp/phase719_worker_volume_line_patch_body.json || true)"

printf '%s\n' "$CREATE_RESPONSE" > checkpoints/PHASE719_WORKER_VOLUME_LINE_PATCH_CREATE_RESPONSE.json

TASK_ID="$(printf '%s' "$CREATE_RESPONSE" | python3 -c 'import json,sys

try:

    print(json.load(sys.stdin).get("task_id",""))

except Exception:

    print("")

')"

sleep 8

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "TASK_ID"

  echo "$TASK_ID"

  echo ""

  echo "DASHBOARD ARTIFACT FILES"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'find /app/data/artifacts -maxdepth 2 -type f -print 2>/dev/null | sort | tail -20' || true

  echo ""

  echo "WORKER ARTIFACT FILES"

  docker exec motherboard_systems_hq-worker-1 sh -lc 'find /app/data/artifacts -maxdepth 2 -type f -print 2>/dev/null | sort | tail -20' || true

  echo ""

  echo "ARTIFACT PREVIEW ROUTE"

  if [ -n "$TASK_ID" ]; then

    curl -i -s --max-time 15 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 220 || true

  else

    echo "No task id available."

  fi

  echo ""

  echo "COMPOSE MARKERS"

  grep -nE 'worker_artifacts|/app/data/artifacts|guidance_data|worker:|dashboard:|volumes:' docker-compose.yml || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 160 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "WORKER LOGS"

  docker logs --tail 160 motherboard_systems_hq-worker-1 || true

} | tee "$OUT"

git add "$TARGET"

git add PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_LINE_PATCH.sh

git add checkpoints/PHASE719_DOCKER_COMPOSE_PRE_WORKER_VOLUME_LINE_PATCH.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_POST_WORKER_VOLUME_LINE_PATCH.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_WORKER_VOLUME_LINE_PATCH_CONFIG.txt

git add checkpoints/PHASE719_WORKER_VOLUME_LINE_PATCH_CREATE_RESPONSE.json

git add "$OUT"

git commit -m "Phase 719: attach worker artifact volume by line patch"

git push origin "$BRANCH"

echo "===== WORKER ARTIFACT VOLUME LINE PATCH COMPLETE ====="

