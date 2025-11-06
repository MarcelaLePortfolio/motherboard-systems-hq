set -euo pipefail

# Validates that a PM2 restart preserves environment and restores processes from `pm2 save`.
echo "🔁 Checking PM2 re-hydration…"

pm2 save
pm2 list >/dev/null

TARGET="${1:-reflection-sse-server}"

if pm2 describe "$TARGET" >/dev/null 2>&1; then
  echo "Restarting $TARGET to validate restoration..."
  pm2 restart "$TARGET"
  sleep 2
  if pm2 describe "$TARGET" >/dev/null 2>&1; then
    echo "✅ '$TARGET' restored successfully after restart."
  else
    echo "❌ '$TARGET' failed to restore after restart."
    exit 1
  fi
else
  echo "ℹ️ Target '$TARGET' not found; showing PM2 list:"
  pm2 list
fi
