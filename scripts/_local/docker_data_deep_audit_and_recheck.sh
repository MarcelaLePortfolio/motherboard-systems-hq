#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/docker_data_deep_audit_and_recheck_${STAMP}.txt"

DOCKER_DATA_DIR="$HOME/Library/Containers/com.docker.docker/Data"
DOCKER_RUN_DIR="$HOME/.docker/run"

{
echo "DOCKER DATA DEEP AUDIT AND RECHECK"
echo "Timestamp: $(date)"
echo
echo "SAFETY POSTURE"
echo "- Read-only audit only."
echo "- No deletion of images, containers, volumes, databases, or project files."
echo "- No repo code mutation."
echo

echo "==== HOST DISK ===="
df -h /
echo

echo "==== TOP-LEVEL DOCKER DATA USAGE ===="
du -sh "$DOCKER_DATA_DIR"/* 2>/dev/null | sort -h || true
echo

echo "==== DEEP AUDIT: LARGEST PATHS UNDER DOCKER DATA (TOP 120) ===="
du -xhd 6 "$DOCKER_DATA_DIR" 2>/dev/null | sort -h | tail -n 120 || true
echo

echo "==== SUSPECT VM / DISK / IMAGE FILES ===="
find "$DOCKER_DATA_DIR" -type f \( \
  -name '*.raw' -o \
  -name '*.qcow2' -o \
  -name '*.img' -o \
  -name '*.iso' -o \
  -name '*.vhdx' -o \
  -name 'Docker.raw' -o \
  -name 'data.qcow2' \
\) -exec ls -lh {} \; 2>/dev/null | sort -k5 -h || true
echo

echo "==== LARGE FILES UNDER DOCKER DATA (>500M) ===="
find "$DOCKER_DATA_DIR" -type f -size +500M -exec ls -lh {} \; 2>/dev/null | sort -k5 -h || true
echo

echo "==== DOCKER RUN DIR ===="
ls -la "$DOCKER_RUN_DIR" 2>/dev/null || true
echo

echo "==== DOCKER CLIENT / SERVER RECHECK ===="
docker version 2>&1 || true
echo
docker info 2>&1 || true
echo

echo "==== CONTEXT RECHECK ===="
docker context ls 2>&1 || true
echo

echo "==== LOCAL DASHBOARD STATUS ===="
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
curl -I -sS http://127.0.0.1:3000/ || true
echo

echo "==== DOCKERIZED DASHBOARD STATUS ===="
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
curl -I -sS http://127.0.0.1:8080/ || true
echo

echo "==== INTERPRETATION BOUNDARY ===="
echo "This audit identifies where Docker Desktop data usage is concentrated."
echo "It does not delete anything."
echo "It does not mutate application code."
echo "It does not restart Docker."
echo

} > "$OUT"

echo "Audit written to:"
echo "$OUT"

echo
echo "----- AUDIT PREVIEW -----"
sed -n '1,320p' "$OUT"
