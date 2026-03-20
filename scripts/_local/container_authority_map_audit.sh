#!/usr/bin/env bash
set -euo pipefail

OUT="CONTAINER_AUTHORITY_MAP_AUDIT.txt"

{
  echo "CONTAINER AUTHORITY MAP AUDIT"
  echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
  echo

  echo "== Compose files in repo root =="
  find . -maxdepth 1 -type f \
    \( -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' -o -name 'compose*.yml' -o -name 'compose*.yaml' \) \
    | sort
  echo

  echo "== Dockerfiles in repo root =="
  find . -maxdepth 1 -type f \
    \( -name 'Dockerfile*' -o -name 'Containerfile*' \) \
    | sort
  echo

  echo "== dashboard service declarations =="
  rg -n '^[[:space:]]{2}dashboard:|dockerfile:|image:|build:' docker-compose*.yml docker-compose*.yaml 2>/dev/null || true
  echo

  echo "== worker service declarations =="
  rg -n 'workerA:|workerB:|worker:|dockerfile:|image:|build:' docker-compose*.yml docker-compose*.yaml 2>/dev/null || true
  echo

  echo "== Active dockerfile references =="
  rg -n 'dockerfile:[[:space:]]*' docker-compose*.yml docker-compose*.yaml 2>/dev/null || true
  echo

  echo "== Dashboard helper scripts that rebuild or restore containers =="
  rg -n 'docker compose .*dashboard|docker-compose .*dashboard|docker load|docker save|Dockerfile.dashboard|Dockerfile' \
    scripts scripts/_local 2>/dev/null || true
  echo

  echo "== CI files referencing compose =="
  rg -n 'docker compose|docker-compose|Dockerfile|dockerfile:' .github/workflows scripts 2>/dev/null || true
  echo

  echo "== Safe conclusion =="
  echo "Do not modify Dockerfile or compose topology until the authority file is confirmed."
  echo "Prefer the file referenced by docker-compose.yml dashboard.build.dockerfile."
} > "$OUT"

cat "$OUT"
