
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — MATILDA MODEL ARCHITECTURE INSPECTION"

echo ""

echo "[1] Confirm backup checkpoint exists"

find "/Volumes/Rio Drive/Motherboard_Storage/snapshots" -maxdepth 1 -type d | sort | tail -5

echo ""

echo "[2] Existing chat/model candidate files"

find . \

  -path "./node_modules" -prune -o \

  -path "./.next" -prune -o \

  -path "./_snapshots" -prune -o \

  -path "./snapshots" -prune -o \

  -type f \( -iname "*chat*" -o -iname "*ollama*" -o -iname "*matilda*" -o -iname "*router*" \) \

  -print | sort | head -120

echo ""

echo "[3] Focused model references"

grep -RIn \

  --exclude-dir=node_modules \

  --exclude-dir=.next \

  --exclude-dir=.git \

  --exclude-dir=_snapshots \

  --exclude-dir=snapshots \

  -E "ollama|gemma|model|chat|Matilda|matilda" \

  server.mjs server.js server routes scripts agents src *.ts *.mjs 2>/dev/null | head -220 || true

echo ""

echo "[4] Inspect primary candidates if present"

for f in \

  ollamaChat.ts \

  scripts/utils/ollamaChat.ts \

  matilda_chat.ts \

  agents/matilda.ts/utils/matilda_chat.ts \

  scripts/agents/matilda/askRouter.runtime.ts \

  server/api/chat.mjs \

  routes/api-chat.ts

do

  if [ -f "$f" ]; then

    echo ""

    echo "===== $f ====="

    sed -n '1,180p' "$f"

  fi

done

echo ""

echo "[5] Runtime still healthy"

docker compose ps

echo ""

echo "[6] Git status"

git status --short

echo ""

echo "DONE"

