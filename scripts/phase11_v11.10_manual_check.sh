#!/bin/bash
set -e

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

echo "────────────────────────────────────────────"
echo " Phase 11 v11.10 – Manual Functional Check "
echo "────────────────────────────────────────────"
echo
echo "1) Open the dashboard in your browser:"
echo " http://127.0.0.1:8080/dashboard
"
echo
echo "2) OPS pill:"
echo " - Should be visible at the top-left."
echo " - Text is expected to remain: OPS: Unknown (SSE disabled in v11.10)."
echo
echo "3) Matilda Chat:"
echo " - Type a short message in the Matilda chat box."
echo " - Submit the form."
echo " - Expect the Project Visual Output area to show a 'thinking' message,"
echo " then Matilda's reply or raw JSON."
echo
echo "4) Task Delegation:"
echo " - Enter a task description in the delegation input."
echo " - Submit the form."
echo " - Expect:"
echo " * 'Delegating: ...' line in the delegation log."
echo " * 'Delegated ✓ (id: ..., status: ...)' after API response."
echo " * Optional JSON payload rendered in the Project Visual Output area."
echo
echo "5) Open DevTools console and confirm:"
echo " - No red errors related to chat or delegation handlers."
echo " - No OPS SSE EventSource errors (SSE is disabled by design in v11.10)."
echo
echo "When done, return to ChatGPT and describe what you observed."
