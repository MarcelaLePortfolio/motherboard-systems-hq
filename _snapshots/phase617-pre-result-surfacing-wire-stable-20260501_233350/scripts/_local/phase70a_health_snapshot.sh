#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 70A — OPERATOR HEALTH SNAPSHOT"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "-------------------------------------"

echo ""
echo "GIT HEALTH"
git status --porcelain || true
git rev-parse --abbrev-ref HEAD
git describe --tags --always || true

echo ""
echo "LAYOUT CONTRACT CHECK"
bash scripts/_local/phase65_pre_commit_protection_gate.sh >/dev/null && echo "PASS" || echo "FAIL"

echo ""
echo "DOCKER HEALTH"
docker compose ps

echo ""
echo "DASHBOARD CONTAINER STATUS"
docker inspect -f '{{.State.Status}}' dashboard || true

echo ""
echo "TELEMETRY DRIFT CHECK"
if [ -f scripts/_local/phase68_drift_detection.sh ]; then
  bash scripts/_local/phase68_drift_detection.sh || true
else
  echo "drift script not present"
fi

echo ""
echo "REPLAY VALIDATION CHECK"
if [ -f scripts/_local/phase69_replay_validation.sh ]; then
  bash scripts/_local/phase69_replay_validation.sh || true
else
  echo "replay script not present"
fi

echo ""
echo "CONTAINER LOG SANITY"
docker logs dashboard --tail 20 || true

echo ""
echo "HEALTH SNAPSHOT COMPLETE"
