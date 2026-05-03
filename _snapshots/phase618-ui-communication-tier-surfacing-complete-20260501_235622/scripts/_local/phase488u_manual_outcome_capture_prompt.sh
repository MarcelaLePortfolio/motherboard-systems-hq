#!/bin/bash
set -euo pipefail

open -na "Google Chrome" --args --auto-open-devtools-for-tabs http://localhost:8080/

echo
echo "=== MANUAL OUTCOME CHECK ==="
echo "1. Hard refresh the page"
echo "2. Click 'Quick check' once"
echo "3. Report exactly one of these back in chat:"
echo "   REPLY WORKED"
echo "   TIMEOUT HIT"
echo "   NO UI CHANGE"
echo
echo "If there is any console output at click time, paste that too."
