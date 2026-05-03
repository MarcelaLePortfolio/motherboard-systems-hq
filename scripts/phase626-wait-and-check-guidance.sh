#!/usr/bin/env bash
set -euo pipefail

for i in {1..30}; do
  if curl -fsS http://localhost:3000/api/health >/dev/null 2>&1; then
    echo "Dashboard healthy."
    break
  fi

  if [ "$i" -eq 30 ]; then
    echo "ERROR: dashboard did not become healthy"
    docker compose logs --tail=80 dashboard
    exit 1
  fi

  sleep 1
done

./scripts/phase626-check-api-guidance.sh
