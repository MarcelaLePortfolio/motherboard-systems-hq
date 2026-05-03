#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo
echo "────────────────────────────────────────────"
echo " Phase 11 – OPS Wiring Inspection Helper"
echo "────────────────────────────────────────────"
echo
echo "1) In your browser, open the dashboard:"
echo " -> http://127.0.0.1:8080/dashboard
 (or your mapped port)"
echo
echo "2) In DevTools Console, run:"
echo " window.lastOpsHeartbeat"
echo " window.lastOpsStatusSnapshot"
echo
echo " Note what you see for each (value vs undefined/null)."
echo
echo "When you're done checking in the browser, press ENTER here"
echo "to search the source tree for OPS wiring modules..."
read -r _

echo
echo "🔎 Searching for lastOpsHeartbeat in source..."
rg "lastOpsHeartbeat" public js || true

echo
echo "🔎 Searching for lastOpsStatusSnapshot in source..."
rg "lastOpsStatusSnapshot" public js || true

echo
echo "✅ Done. Copy the outputs above back into ChatGPT so we can"
echo " decide which imports to restore in dashboard-bundle-entry.js."
echo
