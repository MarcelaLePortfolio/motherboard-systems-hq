#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/docker_surgical_space_recovery_${STAMP}.txt"

DOCKER_DATA_DIR="$HOME/Library/Containers/com.docker.docker/Data"
DOCKER_LOG_DIR="$DOCKER_DATA_DIR/log"

{
echo "DOCKER SURGICAL SPACE RECOVERY"
echo "Timestamp: $(date)"
echo
echo "SAFETY POSTURE"
echo "- This script does NOT delete containers, images, volumes, networks, databases, or application code."
echo "- This script does NOT mutate docker-compose files or repo source."
echo "- This script only compresses older Docker Desktop log files and rotated log files."
echo "- Current live .log files are left untouched."
echo

echo "==== HOST DISK BEFORE ===="
df -h /
echo

echo "==== DOCKER DATA BEFORE ===="
du -sh "$DOCKER_DATA_DIR" 2>/dev/null || true
du -sh "$DOCKER_LOG_DIR" 2>/dev/null || true
echo

echo "==== TARGET FILES (PREVIEW) ===="
find "$DOCKER_LOG_DIR" -type f \( \
  -name '*.log.[0-9]*' -o \
  -name 'electron-*.log' -o \
  -name 'electron-errd-*.log' -o \
  -name 'electron-ui-console-*.log' -o \
  -name 'console.log.[0-9]*' -o \
  -name 'init.log.[0-9]*' -o \
  -name 'monitor.log.[0-9]*' -o \
  -name 'httpproxy.log.[0-9]*' -o \
  -name 'com.docker.backend.log.[0-9]*' \
\) ! -name '*.gz' | sort || true
echo

echo "==== TARGET SIZE BEFORE ===="
find "$DOCKER_LOG_DIR" -type f \( \
  -name '*.log.[0-9]*' -o \
  -name 'electron-*.log' -o \
  -name 'electron-errd-*.log' -o \
  -name 'electron-ui-console-*.log' -o \
  -name 'console.log.[0-9]*' -o \
  -name 'init.log.[0-9]*' -o \
  -name 'monitor.log.[0-9]*' -o \
  -name 'httpproxy.log.[0-9]*' -o \
  -name 'com.docker.backend.log.[0-9]*' \
\) ! -name '*.gz' -print0 2>/dev/null | xargs -0 du -ch 2>/dev/null | tail -n 1 || true
echo

echo "==== COMPRESSING TARGET FILES ===="
COUNT=0
find "$DOCKER_LOG_DIR" -type f \( \
  -name '*.log.[0-9]*' -o \
  -name 'electron-*.log' -o \
  -name 'electron-errd-*.log' -o \
  -name 'electron-ui-console-*.log' -o \
  -name 'console.log.[0-9]*' -o \
  -name 'init.log.[0-9]*' -o \
  -name 'monitor.log.[0-9]*' -o \
  -name 'httpproxy.log.[0-9]*' -o \
  -name 'com.docker.backend.log.[0-9]*' \
\) ! -name '*.gz' -print0 2>/dev/null | while IFS= read -r -d '' f; do
  echo "Compressing: $f"
  gzip -9 "$f"
  COUNT=$((COUNT + 1))
done
echo "Compression pass complete"
echo

echo "==== GZ FILES AFTER ===="
find "$DOCKER_LOG_DIR" -type f -name '*.gz' | sort || true
echo

echo "==== DOCKER DATA AFTER ===="
du -sh "$DOCKER_DATA_DIR" 2>/dev/null || true
du -sh "$DOCKER_LOG_DIR" 2>/dev/null || true
echo

echo "==== HOST DISK AFTER ===="
df -h /
echo

echo "==== SAFETY NOTE ===="
echo "Only rotated / historical Docker Desktop logs were compressed."
echo "No Docker images, containers, volumes, project files, or databases were deleted."
echo

} > "$OUT"

echo "Recovery report written to:"
echo "$OUT"

echo
echo "----- RECOVERY REPORT PREVIEW -----"
sed -n '1,260p' "$OUT"
