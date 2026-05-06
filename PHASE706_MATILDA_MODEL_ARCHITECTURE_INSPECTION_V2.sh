
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — MATILDA MODEL ARCHITECTURE INSPECTION V2"

echo ""

echo "[1] Confirm runtime healthy"

docker compose ps

echo ""

echo "[2] Confirm latest snapshot"

find "/Volumes/Rio Drive/Motherboard_Storage/snapshots" -maxdepth 1 -type d | sort | tail -5

echo ""

echo "[3] Candidate Matilda / chat / Ollama files"

find . \( -path "./node_modules" -o -path "./.git" -o -path "./.next" -o -path "./snapshots" -o -path "./_snapshots" \) -prune -o \( -type f \( -iname "*matilda*" -o -iname "*chat*" -o -iname "*ollama*" -o -iname "*router*" \) -print \) | sort | head -200

echo ""

echo "[4] Search for live model references"

grep -RInE "ollama|gemma|llm|model|api/chat|advisory-deterministic|execution boundaries" \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  --exclude-dir=snapshots \

  --exclude-dir=_snapshots \

  . 2>/dev/null | head -250 || true

echo ""

echo "[5] Preview likely live chat files"

for f in \

  server.mjs \

  server.ts \

  routes/api-chat.ts \

  routes/matilda.ts \

  matilda.ts \

  matilda_chat.ts \

  askRouter.runtime.ts \

  askRouter.ts

do

  if [ -f "$f" ]; then

    echo ""

    echo "===== FILE: $f ====="

    sed -n '1,220p' "$f"

  fi

done

echo ""

echo "[6] Git status"

git status --short

echo ""

echo "DONE"

