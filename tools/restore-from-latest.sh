/* eslint-disable import/no-commonjs */
#!/bin/bash

# Dashboard Protection Corridor 3: default-deny historical entrypoint.
if [ "${MOTHERBOARD_ALLOW_LEGACY_DASHBOARD_RESTORE:-}" != "I_ACKNOWLEDGE_LEGACY_DASHBOARD_RESTORE" ]; then
  echo "BLOCKED: Legacy dashboard restoration is disabled." >&2
  echo "Authoritative dashboard: client/dist/index.html" >&2
  exit 78
fi
# ♻️ Restore last backup with flexible folder handling
LATEST=$(ls -1t "$HOME/Desktop"/MOTHERBOARD_SYSTEMS_BACKUP_*.zip 2>/dev/null | head -n 1)
DEST="$HOME/Desktop/Motherboard Systems HQ"
TEMP="restore_tmp_$$"

if [ ! -f "$LATEST" ]; then
  echo "❌ No backup zip found on Desktop"
  exit 1
fi

cd "$HOME/Desktop" || exit 1
rm -rf "$DEST"
mkdir -p "$TEMP"

echo "📦 Extracting $LATEST..."
unzip -q "$LATEST" -d "$TEMP"

ROOT=$(find "$TEMP" -mindepth 1 -maxdepth 1 -type d | head -n 1)
if [ ! -d "$ROOT" ]; then
  echo "❌ Failed to find extracted root folder"
  rm -rf "$TEMP"
  exit 1
fi

mv "$ROOT" "$DEST"
rm -rf "$TEMP"

cd "$DEST" || exit 1
git init
git remote add origin https://github.com/MarcelaLePortfolio/motherboard-systems-hq.git
git add .
git commit -m "<restore> Full restore from $LATEST"
git branch -M main
git push -f origin main

pnpm install
pm2 delete all
pm2 start "./node_modules/.bin/tsx" scripts/_local/launch-cade.ts --name cade
pm2 start "./node_modules/.bin/tsx" scripts/_local/launch-effie.ts --name effie
pm2 start "./node_modules/.bin/tsx" scripts/_local/launch-matilda.ts --name matilda
pm2 start "node scripts/server.cjs" --name ui-server
pm2 save

echo "🌐 Opening UI..."
open http://localhost:3000
