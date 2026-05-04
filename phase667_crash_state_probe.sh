#!/usr/bin/env bash
set -euo pipefail

echo "=== docker compose ps ==="
docker compose ps

echo
echo "=== dashboard inspect state ==="
docker inspect motherboard_systems_hq-dashboard-1 --format 'Status={{.State.Status}} ExitCode={{.State.ExitCode}} Error={{.State.Error}} OOMKilled={{.State.OOMKilled}} Restarting={{.State.Restarting}} StartedAt={{.State.StartedAt}} FinishedAt={{.State.FinishedAt}}' || true

echo
echo "=== guidance request ==="
curl --max-time 8 -v http://localhost:3000/api/guidance || true

echo
echo "=== docker compose ps after request ==="
docker compose ps

echo
echo "=== dashboard logs after request ==="
docker compose logs --tail=260 dashboard

echo
echo "=== route + engine headers ==="
nl -ba server/routes/operator-guidance.mjs | sed -n '1,120p'
nl -ba server/lib/guidance-engine.js | sed -n '1,160p'

echo
echo "=== git state ==="
git log --oneline --decorate -8
git status --short
