/* eslint-disable import/no-commonjs */
#!/bin/zsh

# Dashboard Protection Corridor 3: default-deny historical entrypoint.
if [ "${MOTHERBOARD_ALLOW_LEGACY_DASHBOARD_RESTORE:-}" != "I_ACKNOWLEDGE_LEGACY_DASHBOARD_RESTORE" ]; then
  echo "BLOCKED: Legacy dashboard restoration is disabled." >&2
  echo "Authoritative dashboard: client/dist/index.html" >&2
  exit 78
fi
set -e

RESTORE_ZIP="$1"
if [ -z "$RESTORE_ZIP" ]; then
    echo "Usage: restore-now <backup_zip>"
    exit 1
fi

DESKTOP=~/Desktop
UNZIP_DIR="$DESKTOP/Motherboard_Restore_$(date +%Y%m%d_%H%M)"
mkdir -p "$UNZIP_DIR"

echo "🔹 Extracting backup..."
unzip -q "$DESKTOP/$RESTORE_ZIP" -d "$UNZIP_DIR"

RESTORED_PROJECT=$(find "$UNZIP_DIR" -maxdepth 1 -type d -name "Motherboard_FullBackup_*")

# 1️⃣ Restore project safely
rsync -av --ignore-existing "$RESTORED_PROJECT/project/" "$DESKTOP/Motherboard_Systems_HQ/"

# 2️⃣ Restore PM2 dump (optional)
cp "$RESTORED_PROJECT/pm2/dump.pm2" ~/.pm2/dump.pm2
pm2 kill
pm2 resurrect || echo "⚠️ PM2 resurrect failed; start apps manually."

# 3️⃣ Verify
"$DESKTOP/Motherboard_Systems_HQ/tools/verify-critical.sh"

echo "✅ Restore complete: Motherboard_Systems_HQ is ready."

# 4️⃣ Cleanup temp folder
rm -rf "$UNZIP_DIR"
echo "🧹 Temporary folder cleaned up."
