#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase473_4_trace_container_public_sync_root_cause.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 473.4 — TRACE CONTAINER PUBLIC SYNC ROOT CAUSE"
  echo "===================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Locate compose and Docker build definitions"
  rg -n "dashboard:|build:|image:|volumes:|public|Dockerfile|context:" \
    docker-compose.yml docker-compose.yaml compose.yml compose.yaml Dockerfile* . \
    --glob '!node_modules' --glob '!docs' || true
  echo

  echo "STEP 2 — Print dashboard service block from compose files"
  for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
    if [ -f "$f" ]; then
      echo "--- FILE: $f ---"
      sed -n '1,260p' "$f"
      echo
    fi
  done
  echo

  echo "STEP 3 — Print Dockerfiles likely used by dashboard"
  find . -maxdepth 2 -type f \( -iname 'Dockerfile' -o -iname 'Dockerfile.*' \) | sort | while read -r f; do
    echo "--- FILE: $f ---"
    sed -n '1,260p' "$f"
    echo
  done
  echo

  echo "STEP 4 — Inspect live container mounts"
  CID="$(docker compose ps -q dashboard)"
  echo "DASHBOARD_CONTAINER_ID=$CID"
  docker inspect "$CID" --format '{{json .Mounts}}' 2>&1 || true
  echo
  docker inspect "$CID" --format '{{json .Config.Image}}' 2>&1 || true
  echo
  docker inspect "$CID" --format '{{json .HostConfig.Binds}}' 2>&1 || true
  echo

  echo "STEP 5 — Compare host vs container public directory snapshots"
  echo "--- HOST public html files ---"
  find public -maxdepth 1 -type f \( -name '*.html' -o -name '*.htm' \) | sort
  echo
  echo "--- CONTAINER /app/public html files ---"
  docker compose exec -T dashboard sh -lc "find /app/public -maxdepth 1 -type f \\( -name '*.html' -o -name '*.htm' \\) | sort" 2>&1 || true
  echo
  echo "--- HOST minimal_probe checksum ---"
  shasum public/minimal_probe.html 2>&1 || true
  echo
  echo "--- CONTAINER minimal_probe checksum ---"
  docker compose exec -T dashboard sh -lc "sha1sum /app/public/minimal_probe.html" 2>&1 || true
  echo
  echo "--- HOST dashboard checksum ---"
  shasum public/dashboard.html 2>&1 || true
  echo
  echo "--- CONTAINER dashboard checksum ---"
  docker compose exec -T dashboard sh -lc "sha1sum /app/public/dashboard.html" 2>&1 || true
  echo

  echo "STEP 6 — Capture container image creation metadata"
  IMAGE_ID="$(docker inspect "$CID" --format '{{.Image}}' 2>/dev/null || true)"
  echo "IMAGE_ID=$IMAGE_ID"
  if [ -n "$IMAGE_ID" ]; then
    docker image inspect "$IMAGE_ID" --format '{{json .RepoTags}} {{json .Created}} {{json .Config.WorkingDir}}' 2>&1 || true
  fi
  echo

  echo "STEP 7 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  if docker compose exec -T dashboard sh -lc 'test -f /app/public/minimal_probe.html'; then
    echo "CLASSIFICATION: CONTAINER_PUBLIC_TREE_IS_CURRENT"
  else
    echo "CLASSIFICATION: CONTAINER_PUBLIC_TREE_IS_STALE_OR_DIFFERENTLY_SOURCED"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Next mutation must target the exact sync mechanism: bind mount, docker build copy, or wrong compose target."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
