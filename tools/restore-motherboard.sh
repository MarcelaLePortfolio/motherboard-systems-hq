/* eslint-disable import/no-commonjs */
#!/bin/bash

# Dashboard Protection Corridor 3: default-deny historical entrypoint.
if [ "${MOTHERBOARD_ALLOW_LEGACY_DASHBOARD_RESTORE:-}" != "I_ACKNOWLEDGE_LEGACY_DASHBOARD_RESTORE" ]; then
  echo "BLOCKED: Legacy dashboard restoration is disabled." >&2
  echo "Authoritative dashboard: client/dist/index.html" >&2
  exit 78
fi
set -e

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
BACKUP_SCRIPT="$PROJECT_DIR/tools/backup-now.sh"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/restore_$TIMESTAMP.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "⏱️ Restore started at: $(date)"
echo "📂 Log file: $LOG_FILE"

# Step 1: Auto-backup current state
if [ -x "$BACKUP_SCRIPT" ]; then
    echo "🔹 Step 1: Backing up current project..."
    "$BACKUP_SCRIPT" --include-hidden
else
    echo "⚠️ Backup script not found, skipping auto-backup."
fi

# Step 2: Move current project to experimental folder
if [ -d "$PROJECT_DIR" ]; then
    mv "$PROJECT_DIR" "${PROJECT_DIR}_experimental_$(date +%H%M)"
fi

# Step 3: Restore from latest backup
LATEST_BACKUP=$(ls -t ~/Desktop/MOTHERBOARD_SYSTEMS_BACKUP_*.zip | head -n 1)
if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ No backup found!"
    exit 1
fi

echo "📦 Using backup: $LATEST_BACKUP"
rm -rf "$PROJECT_DIR" "${PROJECT_DIR}_tmp"
unzip -q "$LATEST_BACKUP" -d "${PROJECT_DIR}_tmp"
mv "${PROJECT_DIR}_tmp"/* "$PROJECT_DIR"
rm -rf "${PROJECT_DIR}_tmp"

# Step 4: Restart PM2 agents & UI
cd "$PROJECT_DIR"
pm2 delete all || true
TSX=$(which tsx)
pm2 start scripts/_local/agent-runtime/launch-cade.ts --interpreter "$TSX" --name cade --cwd "$PWD"
pm2 start scripts/_local/agent-runtime/launch-effie.ts --interpreter "$TSX" --name effie --cwd "$PWD"
pm2 start scripts/_local/agent-runtime/launch-matilda.ts --interpreter "$TSX" --name matilda --cwd "$PWD"
pm2 start scripts/_local/dev-server.ts --interpreter "$TSX" --name ui-server --cwd "$PWD"
pm2 save

# Step 5: Verification
sleep 3
echo "🌐 Dashboard: http://127.0.0.1:3000/"
echo "📊 Agent status JSON:"
curl -s http://127.0.0.1:3000/agent-status.json || echo "⚠️ Dashboard not responding"

echo
echo "📜 PM2 Snapshot:"
pm2 ls

echo "✅ Restore complete. Log saved to: $LOG_FILE"
