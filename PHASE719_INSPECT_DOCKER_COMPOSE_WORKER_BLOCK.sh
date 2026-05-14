
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT DOCKER COMPOSE WORKER BLOCK ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_DOCKER_COMPOSE_WORKER_BLOCK_INSPECTION.txt"

{

  echo "PHASE 719 DOCKER COMPOSE WORKER BLOCK INSPECTION"

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "HEAD:"

  git log --oneline --decorate -5

  echo ""

  echo "Raw docker-compose.yml:"

  nl -ba docker-compose.yml

  echo ""

  echo "Compose config worker/dashboard volume excerpts:"

  docker compose config | sed -n '/dashboard:/,/postgres:/p'

  echo ""

  docker compose config | sed -n '/worker:/,/networks:/p'

  echo ""

  echo "Current volume markers:"

  grep -nE 'worker_artifacts|/app/data/artifacts|guidance_data|worker:|dashboard:' docker-compose.yml || true

  echo ""

  echo "Runtime health:"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

} | tee "$OUT"

git add PHASE719_INSPECT_DOCKER_COMPOSE_WORKER_BLOCK.sh

git add "$OUT"

git commit -m "Phase 719: inspect compose worker block before volume fix"

git push origin "$BRANCH"

echo "===== DOCKER COMPOSE WORKER BLOCK INSPECTION COMPLETE ====="

