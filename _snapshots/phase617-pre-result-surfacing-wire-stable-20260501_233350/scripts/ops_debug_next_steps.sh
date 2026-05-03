#!/usr/bin/env bash
set -euo pipefail

echo
echo "────────────────────────────────────────────"
echo " OPS Globals Manual Verification Steps"
echo "────────────────────────────────────────────"
echo
echo "1) Open your browser to:"
echo "   [http://127.0.0.1:8080/dashboard](http://127.0.0.1:8080/dashboard)"
echo
echo "2) Open DevTools Console."
echo
echo "3) In the console, run:"
echo "   window.lastOpsHeartbeat"
echo "   window.lastOpsStatusSnapshot"
echo
echo "4) Observe the values and, if needed, copy them"
echo "   back into ChatGPT for further debugging."
echo
