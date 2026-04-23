#!/bin/bash
set -euo pipefail

echo "=== INJECT FRONTEND TRACE LOGGING (SAFE, REVERSIBLE) ==="

python3 << 'PY'
from pathlib import Path

path = Path("public/js/matilda-chat-console.js")
text = path.read_text()

marker = "async function handleSend() {"

if "PHASE488_TRACE" in text:
    print("Trace already injected. Skipping.")
else:
    injection = '''
    // PHASE488_TRACE_START
    console.log("[PHASE488_TRACE] handleSend invoked");
    // PHASE488_TRACE_END
'''

    text = text.replace(marker, marker + injection)

    # after fetch
    text = text.replace(
        'var res = await fetch("/api/chat", {',
        'console.log("[PHASE488_TRACE] sending /api/chat request");\n        var res = await fetch("/api/chat", {'
    )

    # after response
    text = text.replace(
        'var data = await res.json();',
        'console.log("[PHASE488_TRACE] response received");\n        var data = await res.json();\n        console.log("[PHASE488_TRACE] parsed json", data);'
    )

    path.write_text(text)
    print("Trace logging injected.")
PY

docker compose build dashboard
docker compose up -d dashboard
sleep 3

echo
echo "=== OPEN TRACE SESSION ==="
open -na "Google Chrome" --args --auto-open-devtools-for-tabs http://localhost:8080/

echo
echo "=== WHAT TO LOOK FOR ==="
echo "1. Console tab"
echo "2. Send message to Matilda"
echo "3. Confirm logs:"
echo "   [PHASE488_TRACE] handleSend invoked"
echo "   [PHASE488_TRACE] sending /api/chat request"
echo "   [PHASE488_TRACE] response received"
echo "   [PHASE488_TRACE] parsed json"

git add public/js/matilda-chat-console.js
git commit -m "Add temporary frontend trace logging for Matilda chat hang diagnosis"
git push
