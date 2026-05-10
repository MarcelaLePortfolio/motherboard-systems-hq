
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 TERMINAL PASTE RECOVERY CHECK ====="

echo ""

echo "[1] Git status"

git status --short

echo ""

echo "[2] Current HEAD"

git log --oneline --decorate -5

echo ""

echo "[3] Docker status"

docker compose ps --format "table {{.Name}}\t{{.Service}}\t{{.Status}}"

echo ""

echo "[4] Latest external backups"

ls -td "/Volumes/Rio Drive/Motherboard_Storage/snapshots"/phase715-pre-execution-evidence-ui_* 2>/dev/null | head -5

echo ""

echo "===== CHECK COMPLETE ====="

