#!/bin/bash
set -euo pipefail

echo "=== OPEN DEVTOOLS NETWORK-FOCUSED SESSION ==="
open -na "Google Chrome" --args --auto-open-devtools-for-tabs http://localhost:8080/

echo
echo "=== INSTRUCTIONS ==="
echo "1. Go to Network tab"
echo "2. Filter: 'chat'"
echo "3. Send a Matilda message"
echo "4. Click the /api/chat request"
echo "5. Check:"
echo "   - Status (pending? 200? 500?)"
echo "   - Timing tab (stalled? waiting?)"
echo "   - Response tab (empty? error?)"

echo
echo "=== OPTIONAL CURL TEST (DIRECT API) ==="
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"probe","agent":"matilda"}' \
  -v || true

echo
echo "=== DONE ==="
