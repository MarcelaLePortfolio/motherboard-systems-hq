
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: ATTACH WORKER ARTIFACT VOLUME EXACT V2 ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="docker-compose.yml"

OUT="checkpoints/PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_V2_VERIFY.txt"

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_PRE_ATTACH_WORKER_ARTIFACT_VOLUME_V2.yml

python3 - << 'PY'

from pathlib import Path

path = Path("docker-compose.yml")

text = path.read_text()

old_worker = '''  worker:

    build:

      context: .

      dockerfile: Dockerfile

    command: ["node", "server/worker/phase26_task_worker.mjs"]

    depends_on:

      postgres:

        condition: service_healthy

    environment:

      - POSTGRES_URL=postgresql://postgres:postgres@postgres:5432/postgres

      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/postgres

'''

new_worker = '''  worker:

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

'''

if "    volumes:\n      - worker_artifacts:/app/data/artifacts\n" not in text:

    if old_worker not in text:

        raise SystemExit("Exact worker block not found; refusing patch.")

    text = text.replace(old_worker, new_worker, 1)

if "worker_artifacts:" not in text:

    text = text.rstrip() + "\n  worker_artifacts:\n"

path.write_text(text)

PY

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_POST_ATTACH_WORKER_ARTIFACT_VOLUME_V2.yml

docker compose config > checkpoints/PHASE719_DOCKER_COMPOSE_ATTACH_WORKER_ARTIFACT_VOLUME_V2_CONFIG.txt

docker compose up -d --build worker dashboard

sleep 6

cat > /tmp/phase719_attach_worker_artifact_volume_body.json << 'JSON'

{"title":"Phase 719 artifact volume validation after exact worker mount attach V2","agent":"cade","source":"phase719-attach-worker-artifact-volume-v2"}

JSON

CREATE_RESPONSE="$(curl -sS --max-time 15 -X POST 'http://localhost:3000/api/tasks/create' -H 'Content-Type: application/json' --data-binary @/tmp/phase719_attach_worker_artifact_volume_body.json || true)"

printf '%s\n' "$CREATE_RESPONSE" > checkpoints/PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_V2_CREATE_RESPONSE.json

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

  grep -nE 'worker_artifacts|/app/data/artifacts|guidance_data|worker:|dashboard:' docker-compose.yml || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 160 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "WORKER LOGS"

  docker logs --tail 160 motherboard_systems_hq-worker-1 || true

} | tee "$OUT"

git add "$TARGET"

git add PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_EXACT.sh || true

git add PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_EXACT_V2.sh

git add checkpoints/PHASE719_DOCKER_COMPOSE_PRE_ATTACH_WORKER_ARTIFACT_VOLUME_V2.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_POST_ATTACH_WORKER_ARTIFACT_VOLUME_V2.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_ATTACH_WORKER_ARTIFACT_VOLUME_V2_CONFIG.txt

git add checkpoints/PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_V2_CREATE_RESPONSE.json

git add "$OUT"

git commit -m "Phase 719: attach worker artifact volume exactly"

git push origin "$BRANCH"

echo "===== ATTACH WORKER ARTIFACT VOLUME EXACT V2 COMPLETE ====="

