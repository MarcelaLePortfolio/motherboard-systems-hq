
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — FIX PROMPT QUOTE CRASH"

python3 - << 'PY'

from pathlib import Path

for file in ["server.mjs", "server.js"]:

    p = Path(file)

    s = p.read_text()

    bad_double = '"Keep the response natural, helpful, and concise. If the user asks for a systems check, explain that you can interpret dashboard information they provide or visible surfaced state included in the chat context, but you are not directly viewing the dashboard, actively checking systems, gathering live status, or running diagnostics. Do not say phrases like "let\\\'s take a look", "I\\\'m checking", "I\\\'m seeing", or "give me a moment" unless actual read-only context has been provided."'

    bad_double_alt = '"Keep the response natural, helpful, and concise. If the user asks for a systems check, explain that you can interpret dashboard information they provide or visible surfaced state included in the chat context, but you are not directly viewing the dashboard, actively checking systems, gathering live status, or running diagnostics. Do not say phrases like "let\'s take a look", "I\'m checking", "I\'m seeing", or "give me a moment" unless actual read-only context has been provided."'

    good_backtick = '`Keep the response natural, helpful, and concise. If the user asks for a systems check, explain that you can interpret dashboard information they provide or visible surfaced state included in the chat context, but you are not directly viewing the dashboard, actively checking systems, gathering live status, or running diagnostics. Do not say phrases like "let\\\'s take a look", "I\\\'m checking", "I\\\'m seeing", or "give me a moment" unless actual read-only context has been provided.`'

    if bad_double in s:

        s = s.replace(bad_double, good_backtick)

    if bad_double_alt in s:

        s = s.replace(bad_double_alt, good_backtick)

    p.write_text(s)

PY

echo ""

echo "[1] Syntax check"

node --check server.js

node --check server.mjs

echo ""

echo "[2] Rebuild dashboard"

docker compose up -d --build dashboard

echo ""

echo "[3] Wait for HTTP"

for i in $(seq 1 30); do

  if curl -sS -I "http://localhost:3000" >/dev/null 2>&1; then

    echo "Dashboard HTTP ready"

    break

  fi

  echo "waiting... $i"

  sleep 2

done

echo ""

echo "[4] Validate systems-check wording"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[5] Runtime"

docker compose ps

git add server.mjs server.js PHASE706_TIGHTEN_VISIBLE_CONTEXT_LANGUAGE.sh PHASE706_FIX_PROMPT_QUOTE_CRASH.sh

git commit -m "Phase 706: fix Matilda prompt quote crash"

git push

