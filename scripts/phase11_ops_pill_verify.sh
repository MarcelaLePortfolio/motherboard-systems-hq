#!/usr/bin/env bash
set -euo pipefail

echo
echo "────────────────────────────────────────────"
echo " Phase 11 – OPS Pill Visual Verification"
echo "────────────────────────────────────────────"
echo
echo "1) Open your browser to:"
echo "   [http://127.0.0.1:8080/dashboard](http://127.0.0.1:8080/dashboard)"
echo
echo "2) Confirm you see a pill near the top that initially reads:"
echo "   "OPS: Unknown""
echo
echo "3) Wait a few seconds, then refresh once if needed."
echo
echo "4) Open DevTools Console and run:"
echo "   window.lastOpsHeartbeat"
echo "   window.lastOpsStatusSnapshot"
echo
echo "5) Confirm:"
echo "   - window.lastOpsHeartbeat is a recent Unix timestamp"
echo "   - window.lastOpsStatusSnapshot is a non-null object from OPS SSE"
echo
echo "6) Visually confirm the pill updates its text to reflect the current"
echo "   state (e.g., "OPS: Online" if wired that way)."
echo
