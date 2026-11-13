/* eslint-disable import/no-commonjs */
#!/bin/bash

# Dashboard Protection Corridor 3: default-deny historical entrypoint.
if [ "${MOTHERBOARD_ALLOW_LEGACY_DASHBOARD_RESTORE:-}" != "I_ACKNOWLEDGE_LEGACY_DASHBOARD_RESTORE" ]; then
  echo "BLOCKED: Legacy dashboard restoration is disabled." >&2
  echo "Authoritative dashboard: client/dist/index.html" >&2
  exit 78
fi
set -e

echo "🖥️ Restoring Motherboard Dashboard UI..."

cd ~/Desktop/Motherboard_Systems_HQ

# 1️⃣ Backup current UI folder if it exists
TIMESTAMP=$(date +%H%M)
if [ -d "ui/dashboard/public" ]; then
  mv ui/dashboard/public ui/dashboard/public_broken_$TIMESTAMP
  echo "📦 Current UI backed up as ui/dashboard/public_broken_$TIMESTAMP"
fi

# 2️⃣ Extract the UI from the latest full backup
LATEST_BACKUP=$(ls -t ~/Desktop/MOTHERBOARD_SYSTEMS_BACKUP_*.zip | head -n 1)
echo "📦 Using latest backup: $LATEST_BACKUP"
mkdir -p Motherboard_Systems_HQ_tmp
unzip -o "$LATEST_BACKUP" "*/ui/dashboard/public/*" -d Motherboard_Systems_HQ_tmp > /dev/null

# 3️⃣ Move restored files into place
mkdir -p ui/dashboard/public
rsync -av --ignore-existing Motherboard_Systems_HQ_tmp/**/ui/dashboard/public/ ui/dashboard/public/
rm -rf Motherboard_Systems_HQ_tmp

# 4️⃣ Confirm restored files
echo "✅ Restored UI files:"
ls -l ui/dashboard/public/index.html ui/dashboard/public/dash.js ui/dashboard/public/dash.css || true

# 5️⃣ Restart PM2 agents & UI server
echo "🔄 Restarting PM2 processes..."
pm2 delete all || true
TSX=$(which tsx)
pm2 start scripts/_local/agent-runtime/launch-cade.ts --interpreter "$TSX" --name cade --cwd "$PWD"
pm2 start scripts/_local/agent-runtime/launch-effie.ts --interpreter "$TSX" --name effie --cwd "$PWD"
pm2 start scripts/_local/agent-runtime/launch-matilda.ts --interpreter "$TSX" --name matilda --cwd "$PWD"
pm2 start scripts/_local/dev-server.ts --interpreter "$TSX" --name ui-server --cwd "$PWD"
pm2 save

# 6️⃣ Confirm everything is online
sleep 5
echo "🌐 Dashboard available at: http://127.0.0.1:3000/"
curl -s http://127.0.0.1:3000/agent-status.json || true

echo "🎉 Restore complete. Open your dashboard in the browser."
