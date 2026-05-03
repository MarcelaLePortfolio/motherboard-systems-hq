#!/usr/bin/env bash

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/dashboard_down_inspection_${STAMP}.txt"

compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    return 127
  fi
}

{
echo "DASHBOARD DOWN INSPECTION"
echo "Timestamp: $(date -Is)"
echo

echo "==== GIT STATE ===="
git branch --show-current || true
git rev-parse --short HEAD || true
echo

echo "==== CONTAINER STATUS ===="
docker ps || true
echo

echo "==== DASHBOARD CONTAINERS ===="
docker ps -a | grep -i dashboard || true
echo

echo "==== POSTGRES CONTAINERS ===="
docker ps -a | grep -i postgres || true
echo

echo "==== COMPOSE STATUS ===="
compose_cmd ps || true
echo

echo "==== DASHBOARD LOGS ===="
for c in $(docker ps -a --format '{{.Names}}' | grep -i dashboard); do
echo "---- $c ----"
docker logs --tail 200 "$c" || true
echo
done

echo "==== POSTGRES LOGS ===="
for c in $(docker ps -a --format '{{.Names}}' | grep -i postgres); do
echo "---- $c ----"
docker logs --tail 100 "$c" || true
echo
done

echo "==== PORT CHECK ===="
lsof -iTCP -sTCP:LISTEN | grep -E "3000|8080|5432" || true
echo

echo "==== HTTP CHECK ===="
curl -I http://localhost:8080 || true
curl -I http://localhost:3000 || true
echo

} > "$OUT"

echo "Inspection report written to:"
echo "$OUT"

