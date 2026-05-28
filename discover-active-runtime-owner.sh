
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="ACTIVE_RUNTIME_OWNER_DISCOVERY.txt"

PORT="${PORT:-3000}"

rm -f "$OUTPUT"

echo "===== ACTIVE RUNTIME OWNER DISCOVERY =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== PORT OWNER =====" | tee -a "$OUTPUT"

lsof -nP -iTCP:"$PORT" -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER CONTEXT =====" | tee -a "$OUTPUT"

docker context ls 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER PS =====" | tee -a "$OUTPUT"

docker ps -a 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER COMPOSE FILES =====" | tee -a "$OUTPUT"

find . -maxdepth 3 -type f \( -name "docker-compose.yml" -o -name "docker-compose.yaml" -o -name "docker-compose*.yml" -o -name "docker-compose*.yaml" \) | sort | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== COMPOSE PORT REFERENCES =====" | tee -a "$OUTPUT"

grep -Rni "3000:3000\|3000" docker-compose* . 2>/dev/null | grep -v node_modules | head -120 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== PACKAGE / START REFERENCES =====" | tee -a "$OUTPUT"

grep -Rni "\"start\"\|server.mjs\|npm run\|node server\|tsx" package.json docker-compose* Dockerfile* scripts server . 2>/dev/null | grep -v node_modules | head -160 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== PM2 STATUS =====" | tee -a "$OUTPUT"

pm2 ls 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add docs/contracts/GOVERNED_ROUTE_INPROCESS_VALIDATION_CHECKPOINT.md discover-active-runtime-owner.sh ACTIVE_RUNTIME_OWNER_DISCOVERY.txt

git commit -m "Checkpoint governed route validation and discover runtime owner"

git push

