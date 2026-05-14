
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: ATTACH WORKER ARTIFACT VOLUME EXACT ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="docker-compose.yml"

OUT="checkpoints/PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_VERIFY.txt"

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_PRE_ATTACH_WORKER_ARTIFACT_VOLUME.yml

python3 - << 'PY'

from pathlib import Path

path = Path("docker-compose.yml")

text = path.read_text()

worker_block = """  worker:

    build:

      context: .

      dockerfile: Dockerfile

    command: ["node", "server/worker/phase26_task_worker.mjs"]

    depends_on:

      postgres:

        condition: service_healthy

    volumes:

      - worker_artifacts:/app/data/artifacts

    environment:

      - POSTGRES_URL=postgresql://postgres:postgres@postgres:5432/postgres

      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/postgres

"""

if "volumes:\n      - worker_artifacts:/app/data/artifacts" not in text:

    start = text.find("  worker:\n")

    if start == -1:

        raise SystemExit("worker block not found")

    end = text.find("\n  volumes:\n", start)

    if end == -1:

        raise SystemExit("compose volumes section not found")

    text = text[:start] + worker_block + text[end:]

if "worker_artifacts:" not in text:

    text = text.rstrip() + "\n  worker_artifacts:\n"

path.write_text(text)

PY

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_POST_ATTACH_WORKER_ARTIFACT_VOLUME.yml

docker compose config > checkpoints/PHASE719_DOCKER_COMPOSE_ATTACH_WORKER_ARTIFACT_VOLUME_CONFIG.txt

docker compose up -d --build worker dashboard

sleep 6

cat > /tmp/phase719_attach_worker_artifact_volume_body.json << 'JSON'

{

  "title":"Phase 719 artifact volume validation after exact worker mount attach",

  "agent":"cade",

  "source":"phase719-attach-worker-artifact-volume"

}

JSON

CREATE_RESPONSE="$(curl -sS --max-time 15 -X POST "http://localhost:3000/api/tasks/create" -H "Content-Type: application/json" --data-binary @/tmp/phase719_attach_worker_artifact_volume_body.json || true)"

printf '%s\n' "$CREATE_RESPONSE" > checkpoints/PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_CREATE_RESPONSE.json

TASK_ID="$(printf '%s' "$CREATE_RESPONSE" | python3 -c 'import json,sys

try:

    print(json.load(sys.stdin).get("task_id",""))

except Exception:

    print("")

')"

sleep 8

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

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

    curl -i -s --max-time 15 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 200 || true

  else

    echo "No task id available."

  fi

  echo ""

  echo "COMPOSE MARKERS"

  grep -nE 'worker_artifacts|/app/data/artifacts|guidance_data|worker:|dashboard:' docker-compose.yml || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 160 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "WORKER LOGS"

  docker logs --tail 160 motherboard_systems_hq-worker-1 || true

} | tee "$OUT"

git add "$TARGET"

git add PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_EXACT.sh

git add checkpoints/PHASE719_DOCKER_COMPOSE_PRE_ATTACH_WORKER_ARTIFACT_VOLUME.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_POST_ATTACH_WORKER_ARTIFACT_VOLUME.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_ATTACH_WORKER_ARTIFACT_VOLUME_CONFIG.txt

git add checkpoints/PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_CREATE_RESPONSE.json

git add "$OUT"

git commit -m "Phase 719: attach worker artifact volume exactly"

git push origin "$BRANCH"

echo "===== ATTACH WORKER ARTIFACT VOLUME EXACT COMPLETE ====="

