#!/bin/bash
set -euo pipefail

echo "=== RUN CLEANUP SCRIPT ==="
bash scripts/_local/phase488ab_cleanup_debug_and_finalize.sh

echo
echo "=== FINAL VERIFICATION ==="
echo "1. Hard refresh the browser"
echo "2. Click 'Quick check' once"
echo "3. Confirm Matilda responds normally (no timeout, no debug spam)"

echo
echo "If anything still looks off, stop and report before making more changes."
