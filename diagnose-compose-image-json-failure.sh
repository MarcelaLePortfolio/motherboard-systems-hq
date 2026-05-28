
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="COMPOSE_IMAGE_JSON_FAILURE_DIAGNOSIS.txt"

rm -f "$OUTPUT"

echo "===== COMPOSE IMAGE JSON FAILURE DIAGNOSIS =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== DOCKER SYSTEM INFO =====" | tee -a "$OUTPUT"

docker system df 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== EXISTING IMAGES MATCHING PROJECT =====" | tee -a "$OUTPUT"

docker images 2>&1 | grep -i "motherboard\|dashboard\|postgres" | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== EXISTING CONTAINERS =====" | tee -a "$OUTPUT"

docker container ls -a 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== COMPOSE CONFIG CHECK =====" | tee -a "$OUTPUT"

docker compose config 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== REMOVE BROKEN DASHBOARD IMAGE IF PRESENT =====" | tee -a "$OUTPUT"

docker image rm motherboard-systems-hq-clean-dashboard 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== BUILDKIT PRUNE STALE CACHE =====" | tee -a "$OUTPUT"

docker builder prune -f 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== CONTROLLED DASHBOARD BUILD =====" | tee -a "$OUTPUT"

docker compose build --no-cache dashboard 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== POST-BUILD IMAGES =====" | tee -a "$OUTPUT"

docker images 2>&1 | grep -i "motherboard\|dashboard\|postgres" | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add diagnose-compose-image-json-failure.sh COMPOSE_IMAGE_JSON_FAILURE_DIAGNOSIS.txt COMPOSE_RUNTIME_BASELINE_VALIDATION.txt start-compose-runtime-and-validate-baseline.sh

git commit -m "Diagnose compose image JSON failure" || true

git push

