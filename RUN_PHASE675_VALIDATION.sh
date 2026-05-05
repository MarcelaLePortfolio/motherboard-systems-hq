#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://localhost:8080}"

echo "Using BASE_URL=${BASE_URL}"

# Try to start local stack (Docker first, then fallback to npm)
if command -v docker >/dev/null 2>&1 && [ -f docker-compose.yml ]; then
  echo "Starting containers via docker compose..."
  docker compose up -d --build || true
elif [ -f package.json ]; then
  echo "Starting app via npm..."
  (npm run start >/dev/null 2>&1 &) || true
fi

# Wait for server readiness (max ~60s)
echo "Waiting for ${BASE_URL} to become reachable..."
for i in {1..60}; do
  if curl -fsS "${BASE_URL}" >/dev/null 2>&1; then
    echo "Server is up."
    break
  fi
  sleep 1
done

# Run validation
echo "Running Phase 675 shadow validation..."
NEXT_PUBLIC_BASE_URL="${BASE_URL}" node scripts/validate-phase675-coherence-shadow.mjs
