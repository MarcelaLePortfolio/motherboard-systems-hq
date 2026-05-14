
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: FIX WORKER ARTIFACT VOLUME AND VALIDATE ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="docker-compose.yml"

OUT="checkpoints/PHASE719_WORKER_ARTIFACT_VOLUME_FIX_VERIFY.txt"

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_PRE_WORKER_ARTIFACT_VOLUME_FIX.yml

python3 - << 'PY'

from pathlib import Path

path = Path("docker-compose.yml")

text = path.read_text()

if "worker_artifacts:" not in text:

    text = text.rstrip() + "\n  worker_artifacts:\n"

if "- worker_artifacts:/app/data/artifacts:ro" not in text:

    marker = "      - guidance_data:/app/data\n"

    if marker not in text:

        raise SystemExit("dashboard guidance_data volume marker not found")

    text = text.replace(marker, marker + "      - worker_artifacts:/app/data/artifacts:ro\n", 1)

if "- worker_artifacts:/app/data/artifacts\n" not in text:

    worker_idx = text.find("  worker:\n")

    if worker_idx == -1:

        raise SystemExit("worker service not found")

    next_service = text.find("\n  ", worker_idx + len("  worker:\n"))

    while next_service != -1 and text[next_service:next_service+4].startswith("\n    "):

        next_service = text.find("\n  ", next_service + 1)

    worker_block_end = next_service if next_service != -1 else len(text)

    worker_block = text[worker_idx:worker_block_end]

    if "    volumes:\n" in worker_block:

        worker_block = worker_block.replace("    volumes:\n", "    volumes:\n      - worker_artifacts:/app/data/artifacts\n", 1)

    else:

        env_marker = "    environment:\n"

        if env_marker not in worker_block:

            raise SystemExit("worker environment marker not found")

        worker_block = worker_block.replace(env_marker, "    volumes:\n      - worker_artifacts:/app/data/artifacts\n" + env_marker, 1)

    text = text[:worker_idx] + worker_block + text[worker_block_end:]

path.write_text(text)

PY

docker compose config > checkpoints/PHASE719_DOCKER_COMPOSE_WORKER_ARTIFACT_VOLUME_CONFIG.txt

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_POST_WORKER_ARTIFACT_VOLUME_FIX.yml

docker compose up -d --build worker dashboard

sleep 5

cat > /tmp/phase719_body.json << 'JSON'

{"title":"Phase 719 shared artifact volume validation after worker mount fix: create a rendered proof with headline and three bullets.","agent":"cade","source":"phase719-worker-artifact-volume-validation"}

JSON

CREATE_RESPONSE="$(curl -sS --max-time 10 -X POST 'http://localhost:3000/api/tasks/create' -H 'Content-Type: application/json' --data-binary @/tmp/phase719_body.json || true)"

printf '%s\n' "$CREATE_RESPONSE" > checkpoints/PHASE719_WORKER_VOLUME_FIX_CREATE_RESPONSE.json

TASK_ID="$(printf '%s' "$CREATE_RESPONSE" | python3 -c 'import json,sys

try:

    print(json.load(sys.stdin).get("task_id",""))

except Exception:

    print("")

')"

for i in $(seq 1 30); do

  curl -s --max-time 10 'http://localhost:3000/api/tasks' > /tmp/phase719_tasks.json || true

  STATUS="$(TASK_ID="$TASK_ID" python3 -c 'import json,os

from pathlib import Path

tid=os.environ.get("TASK_ID","")

try:

    data=json.loads(Path("/tmp/phase719_tasks.json").read_text())

    for t in data.get("tasks",[]):

        if t.get("task_id")==tid:

            print(t.get("status",""))

            raise SystemExit

except Exception:

    pass

print("")

')"

  echo "poll $i status=$STATUS"

  if [ "$STATUS" = "completed" ]; then

    break

  fi

  sleep 2

done

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

    curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 180 || true

  else

    echo "No task id found."

  fi

  echo ""

  echo "COMPOSE MARKERS"

  grep -nE 'worker_artifacts|/app/data/artifacts|guidance_data' docker-compose.yml || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 140 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "WORKER LOGS"

  docker logs --tail 140 motherboard_systems_hq-worker-1 || true

} | tee "$OUT"

git add "$TARGET"

git add PHASE719_FIX_WORKER_ARTIFACT_VOLUME_AND_VALIDATE.sh

git add checkpoints/PHASE719_DOCKER_COMPOSE_PRE_WORKER_ARTIFACT_VOLUME_FIX.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_POST_WORKER_ARTIFACT_VOLUME_FIX.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_WORKER_ARTIFACT_VOLUME_CONFIG.txt

git add checkpoints/PHASE719_WORKER_VOLUME_FIX_CREATE_RESPONSE.json

git add "$OUT"

git commit -m "Phase 719: mount shared artifact volume on worker"

git push origin "$BRANCH"

echo "===== WORKER ARTIFACT VOLUME FIX COMPLETE ====="

