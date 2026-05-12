
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/matilda-chat-console.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/matilda-chat-console.js")

text = path.read_text()

if "PHASE719_MATILDA_FRONTEND_TIMEOUT_PATCH" not in text:

    text = text.replace(

        '  async function fetchWithTimeout(url, options, timeoutMs = 10000) {',

        '  // PHASE719_MATILDA_FRONTEND_TIMEOUT_PATCH\n  async function fetchWithTimeout(url, options, timeoutMs = 30000) {',

        1

    )

text = text.replace(

    '          body: JSON.stringify({ message: message, agent: "matilda" }),',

    '          body: JSON.stringify({ input: message, message: message, agent: "matilda" }),',

    1

)

path.write_text(text)

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/js/matilda-chat-console.js | grep -q "PHASE719_MATILDA_FRONTEND_TIMEOUT_PATCH"

curl -fsS http://localhost:3000/js/matilda-chat-console.js | grep -q "input: message"

open "http://localhost:3000"

git add "$TARGET" PHASE719_PATCH_MATILDA_FRONTEND_TIMEOUT.sh

git commit -m "Phase 719: extend Matilda frontend chat timeout"

git push origin dev

