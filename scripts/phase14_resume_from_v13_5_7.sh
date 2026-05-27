#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "────────────────────────────────────────────"
echo " Phase 14 – Resume + Quick Verification"
echo "────────────────────────────────────────────"
echo

echo "1) Git status"
git status
echo

echo "2) Docker: rebuild + start"
docker compose down || true
docker compose up -d --build
echo

echo "3) Health checks (adjust ports if needed)"
set +e
curl -fsS "[http://127.0.0.1:8080/dashboard](http://127.0.0.1:8080/dashboard)" >/dev/null && echo "✅ dashboard ok (8080)" || echo "⚠️ dashboard not reachable (8080)"
curl -fsS "[http://127.0.0.1:8080/api/tasks](http://127.0.0.1:8080/api/tasks)" >/dev/null && echo "✅ /api/tasks ok" || echo "⚠️ /api/tasks not reachable"
set -e
echo

echo "4) SSE smoke (5s) — ensure no persistent curl remains"
( timeout 5 curl -N "[http://127.0.0.1:8080/events/tasks](http://127.0.0.1:8080/events/tasks)" || true ) >/dev/null 2>&1
echo "✅ SSE smoke done (5s)"
echo

echo "5) Show docker ps"
docker ps
echo
echo "Done."
