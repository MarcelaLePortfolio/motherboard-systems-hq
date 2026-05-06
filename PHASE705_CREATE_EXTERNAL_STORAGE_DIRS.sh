
#!/bin/bash

set -euo pipefail

echo "PHASE 705 — CREATE EXTERNAL STORAGE DIRECTORIES"

EXTERNAL_ROOT="/Volumes/Rio Drive/Motherboard_Storage"

echo ""

echo "[1] Confirm external drive"

df -h | grep -E "Filesystem|/Volumes/Rio Drive"

echo ""

echo "[2] Create storage directories"

mkdir -p "$EXTERNAL_ROOT/snapshots"

mkdir -p "$EXTERNAL_ROOT/archives"

mkdir -p "$EXTERNAL_ROOT/logs"

mkdir -p "$EXTERNAL_ROOT/exports"

mkdir -p "$EXTERNAL_ROOT/inactive_repos"

echo ""

echo "[3] Verify created directories"

find "$EXTERNAL_ROOT" -maxdepth 2 -type d | sort

echo ""

echo "[4] Runtime remains untouched"

docker compose ps || true

echo ""

echo "DONE"

