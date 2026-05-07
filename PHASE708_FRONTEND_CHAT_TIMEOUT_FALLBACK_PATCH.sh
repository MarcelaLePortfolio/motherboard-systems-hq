
#!/bin/bash

set -euo pipefail

echo "PHASE 708 — FRONTEND CHAT TIMEOUT FALLBACK PATCH"

python3 - << 'PY'

from pathlib import Path

p = Path("public/js/matilda-chat-console.js")

s = p.read_text()

old = 'appendMessage(transcript, "Matilda", "(timeout or network failure)");'

new = 'appendMessage(transcript, "Matilda", "I could not reach the chat service from this browser request, but no execution was attempted. You can retry, or use the visible dashboard/context state for advisory interpretation.");'

if old not in s:

    raise SystemExit("Target timeout fallback line not found in public/js/matilda-chat-console.js")

s = s.replace(old, new, 1)

p.write_text(s)

PY

echo ""

echo "[1] Inspect patched frontend fallback"

grep -nE "timeout|network|could not reach|appendMessage|/api/chat" public/js/matilda-chat-console.js

echo ""

echo "[2] Runtime"

docker compose ps

echo ""

echo "[3] Backend chat sanity"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[4] Context endpoint sanity"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[5] Git status"

git status --short

git add public/js/matilda-chat-console.js PHASE708_FRONTEND_CHAT_TIMEOUT_FALLBACK_PATCH.sh

git commit -m "Phase 708: add truthful frontend chat timeout fallback"

git push

