#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — API SURFACE DISCOVERY"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

echo
echo "== git status --short =="
git status --short

echo
echo "== docker compose ps =="
docker compose ps

echo
echo "== docker compose config services =="
docker compose config --services

echo
echo "== dashboard container logs (last 120 lines) =="
docker compose logs --tail=120 dashboard || true

echo
echo "== postgres container logs (last 60 lines) =="
docker compose logs --tail=60 postgres || true

echo
echo "== route/path search in repo =="
rg -n 'health|/health|tasks|/tasks|logs|/logs|delegate|/delegate|matilda|/api/' . \
  -g '!node_modules' \
  -g '!.next' \
  -g '!.git' \
  -g '!dist' \
  -g '!.runtime' || true

echo
echo "== probe likely dashboard-served api paths on 8080 =="
for path in \
  /api/health \
  /api/tasks \
  /api/logs \
  /api/delegate \
  /health \
  /tasks \
  /logs \
  /delegate
do
  echo
  echo "-- GET http://localhost:8080$path --"
  curl -i -s "http://localhost:8080$path" | sed -n '1,40p' || true
done

echo
echo "────────────────────────────────"
echo "PHASE 487 — API SURFACE DISCOVERY COMPLETE"
echo "────────────────────────────────"
