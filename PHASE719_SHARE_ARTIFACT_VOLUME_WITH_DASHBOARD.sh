
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: SHARE ARTIFACT VOLUME WITH DASHBOARD ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="docker-compose.yml"

TASK_ID="t_d1efc418-5049-401c-89fe-19eaceb8f784"

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_PRE_ARTIFACT_VOLUME.yml

python3 - << 'PY'

from pathlib import Path

path = Path("docker-compose.yml")

text = path.read_text()

if "worker_artifacts:" not in text:

    text += "\n  worker_artifacts:\n"

if "- worker_artifacts:/app/data/artifacts" not in text:

    marker = "      - guidance_data:/app/data\n"

    if marker not in text:

        raise SystemExit("Could not locate dashboard guidance_data volume marker.")

    text = text.replace(marker, marker + "      - worker_artifacts:/app/data/artifacts:ro\n", 1)

if "worker_artifacts:/app/data/artifacts" not in text.replace(":ro", ""):

    worker_marker = "    environment:\n"

    idx = text.find("  worker:\n")

    if idx == -1:

        raise SystemExit("Could not locate worker service.")

    after_worker = text.find(worker_marker, idx)

    if after_worker == -1:

        raise SystemExit("Could not locate worker environment marker.")

    text = text[:after_worker] + "    volumes:\n      - worker_artifacts:/app/data/artifacts\n" + text[after_worker:]

path.write_text(text)

PY

docker compose config >/tmp/phase719_compose_config_check.txt

cp "$TARGET" checkpoints/PHASE719_DOCKER_COMPOSE_POST_ARTIFACT_VOLUME.yml

cp /tmp/phase719_compose_config_check.txt checkpoints/PHASE719_DOCKER_COMPOSE_ARTIFACT_VOLUME_CONFIG.txt

docker compose up -d --build dashboard worker

sleep 5

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "DASHBOARD ARTIFACT FILES"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'find /app/data/artifacts -maxdepth 2 -type f -print 2>/dev/null | head -20' || true

  echo ""

  echo "WORKER ARTIFACT FILES"

  docker exec motherboard_systems_hq-worker-1 sh -lc 'find /app/data/artifacts -maxdepth 2 -type f -print 2>/dev/null | head -20' || true

  echo ""

  echo "ARTIFACT PREVIEW ROUTE"

  curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 160 || true

  echo ""

  echo "DOCKER COMPOSE VOLUME MARKERS"

  grep -nE "worker_artifacts|/app/data/artifacts|guidance_data" docker-compose.yml || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_VERIFY.txt

git add "$TARGET"

git add PHASE719_SHARE_ARTIFACT_VOLUME_WITH_DASHBOARD.sh

git add checkpoints/PHASE719_DOCKER_COMPOSE_PRE_ARTIFACT_VOLUME.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_POST_ARTIFACT_VOLUME.yml

git add checkpoints/PHASE719_DOCKER_COMPOSE_ARTIFACT_VOLUME_CONFIG.txt

git add checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_VERIFY.txt

git commit -m "Phase 719: share artifact volume with dashboard"

git push origin "$BRANCH"

echo "===== SHARED ARTIFACT VOLUME PATCH COMPLETE ====="

