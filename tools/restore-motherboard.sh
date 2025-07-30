#!/bin/zsh
set -e

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
BACKUP_SCRIPT="$PROJECT_DIR/tools/backup-now.sh"

echo "🔹 Step 1: Running pre-restore backup..."
if [ -x "$BACKUP_SCRIPT" ]; then
    "$BACKUP_SCRIPT" --include-hidden
else
    echo "⚠️ Backup script not found, skipping auto-backup."
fi

echo "🔹 Step 2: Moving current project to experimental folder..."
if [ -d "$PROJECT_DIR" ]; then
    mv "$PROJECT_DIR" "${PROJECT_DIR}_experimental_$(date +%H%M)"
fi

echo "🔹 Step 3: Restoring from latest backup..."
LATEST_BACKUP=$(ls -t ~/Desktop/MOTHERBOARD_SYSTEMS_BACKUP_*.zip | head -n 1)
if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ No backup found!"
    exit 1
fi

rm -rf "$PROJECT_DIR" "${PROJECT_DIR}_tmp"
unzip -q "$LATEST_BACKUP" -d "${PROJECT_DIR}_tmp"
mv "${PROJECT_DIR}_tmp"/* "$PROJECT_DIR"
rm -rf "${PROJECT_DIR}_tmp"

echo "🔹 Step 4: Restarting PM2 agents and UI..."
cd "$PROJECT_DIR"
pm2 delete all || true
TSX=$(which tsx)
pm2 start scripts/_local/agent-runtime/launch-cade.ts --interpreter "$TSX" --name cade --cwd "$PWD"
pm2 start scripts/_local/agent-runtime/launch-effie.ts --interpreter "$TSX" --name effie --cwd "$PWD"
pm2 start scripts/_local/agent-runtime/launch-matilda.ts --interpreter "$TSX" --name matilda --cwd "$PWD"
pm2 start scripts/_local/dev-server.ts --interpreter "$TSX" --name ui-server --cwd "$PWD"
pm2 save

echo "🔹 Step 5: Verification..."
sleep 3
echo "🌐 Dashboard: http://127.0.0.1:3000/"
echo "📊 Agent status JSON:"
curl -s http://127.0.0.1:3000/agent-status.json || echo "⚠️ Dashboard not responding"

echo
echo "✅ Restore complete. Agents should be green in the UI."
