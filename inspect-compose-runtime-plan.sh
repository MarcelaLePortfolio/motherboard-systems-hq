
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="COMPOSE_RUNTIME_RESTORATION_PLAN.txt"

rm -f "$OUTPUT"

echo "===== COMPOSE RUNTIME RESTORATION PLAN =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER CONTEXT =====" | tee -a "$OUTPUT"

docker context show 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== COMPOSE CONFIG SERVICES =====" | tee -a "$OUTPUT"

docker compose config --services 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== COMPOSE CONFIG PORTS / DASHBOARD REFERENCES =====" | tee -a "$OUTPUT"

docker compose config 2>&1 | grep -n "dashboard\|8080\|3000\|server.mjs\|Dockerfile.dashboard" | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER COMPOSE FILE HEAD =====" | tee -a "$OUTPUT"

sed -n '1,140p' docker-compose.yml 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER COMPOSE OVERRIDE HEAD =====" | tee -a "$OUTPUT"

sed -n '1,120p' docker-compose.override.yml 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DOCKERFILE DASHBOARD HEAD =====" | tee -a "$OUTPUT"

sed -n '1,120p' Dockerfile.dashboard 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== CURRENT CONTAINERS =====" | tee -a "$OUTPUT"

docker container ls -a 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== CURRENT PORT OWNERS =====" | tee -a "$OUTPUT"

lsof -nP -iTCP:3000 -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

lsof -nP -iTCP:8080 -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== RECOMMENDED NEXT COMMAND =====" | tee -a "$OUTPUT"

echo "docker compose up -d dashboard" | tee -a "$OUTPUT"

echo "Then validate: docker compose ps && curl -i http://localhost:8080/api/health" | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add inspect-compose-runtime-plan.sh COMPOSE_RUNTIME_RESTORATION_PLAN.txt

git commit -m "Inspect compose runtime restoration plan" || true

git push

