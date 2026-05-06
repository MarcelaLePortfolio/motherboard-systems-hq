
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — TIGHTEN VISIBLE CONTEXT LANGUAGE"

python3 - << 'PY'

from pathlib import Path

for file in ["server.mjs", "server.js"]:

    p = Path(file)

    s = p.read_text()

    old = "Keep the response natural, helpful, and concise. If the user asks for a systems check, explain that you can interpret visible dashboard state if provided, but you are not actively checking or gathering anything."

    new = "Keep the response natural, helpful, and concise. If the user asks for a systems check, explain that you can interpret dashboard information they provide or visible surfaced state included in the chat context, but you are not directly viewing the dashboard, actively checking systems, gathering live status, or running diagnostics. Do not say phrases like \"let's take a look\", \"I'm checking\", \"I'm seeing\", or \"give me a moment\" unless actual read-only context has been provided."

    if old not in s:

        raise SystemExit(f"Expected prompt text not found in {file}")

    s = s.replace(old, new)

    p.write_text(s)

PY

echo ""

echo "[1] Rebuild dashboard"

docker compose up -d --build dashboard

echo ""

echo "[2] Wait"

sleep 12

echo ""

echo "[3] Validate systems-check wording"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[4] Validate natural chat"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Hello Matilda. What can you help with?"}' | jq .

echo ""

echo "[5] Validate execution refusal"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Restart the worker and run a task."}' | jq .

echo ""

echo "[6] Runtime"

docker compose ps

echo ""

echo "[7] Storage"

df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive"

docker system df

git add server.mjs server.js PHASE706_TIGHTEN_VISIBLE_CONTEXT_LANGUAGE.sh

git commit -m "Phase 706: tighten Matilda visible context language"

git push

