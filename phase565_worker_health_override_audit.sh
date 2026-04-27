#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 565 — WORKER HEALTHCHECK OVERRIDE AUDIT"
echo "─────────────────────────────────────────────"

echo ""
echo "1. docker-compose worker healthcheck override:"
sed -n '1,120p' docker-compose.worker-healthcheck.override.yml || true

echo ""
echo "2. phase45 startup determinism override:"
sed -n '1,120p' docker-compose.phase45_1.startup_determinism.yml || true

echo ""
echo "3. active compose config healthcheck sections:"
docker compose config | sed -n '/worker:/,/^[^ ]/p' | grep -n "healthcheck\\|test:\\|interval:\\|timeout:\\|retries:\\|start_period:" || true
