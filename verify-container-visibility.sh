
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="CONTAINER_VISIBILITY_VERIFICATION.txt"

rm -f "$OUTPUT"

echo "===== CONTAINER VISIBILITY VERIFICATION =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER VERSION =====" | tee -a "$OUTPUT"

docker version 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER CONTEXT =====" | tee -a "$OUTPUT"

docker context show 2>&1 | tee -a "$OUTPUT" || true

docker context ls 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== ALL CONTAINERS =====" | tee -a "$OUTPUT"

docker container ls -a 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== COMPOSE PROJECTS =====" | tee -a "$OUTPUT"

docker compose ls 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== COMPOSE PS =====" | tee -a "$OUTPUT"

docker compose ps -a 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== PORT 3000 / 8080 OWNERS =====" | tee -a "$OUTPUT"

lsof -nP -iTCP:3000 -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

lsof -nP -iTCP:8080 -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add verify-container-visibility.sh CONTAINER_VISIBILITY_VERIFICATION.txt

git commit -m "Verify container visibility for runtime restoration" || true

git push

