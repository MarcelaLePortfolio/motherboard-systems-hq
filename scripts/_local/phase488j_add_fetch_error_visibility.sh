#!/bin/bash
set -euo pipefail

python3 << 'PY'
from pathlib import Path

path = Path("public/js/matilda-chat-console.js")
text = path.read_text()

if "[matilda-chat][DEBUG_FETCH_WRAP]" in text:
    print("Fetch debug wrapper already present.")
else:
    text = text.replace(
        'var res = await fetch("/api/chat", {',
        '''console.log("[matilda-chat][DEBUG_FETCH_WRAP] initiating fetch");
        let res;
        try {
          res = await fetch("/api/chat", {'''
    )

    text = text.replace(
        'var data = await res.json();',
        '''if (!res) {
          console.error("[matilda-chat][DEBUG_FETCH_WRAP] fetch returned undefined");
          return;
        }
        console.log("[matilda-chat][DEBUG_FETCH_WRAP] status:", res.status);
        let data;
        try {
          data = await res.json();
        } catch (e) {
          console.error("[matilda-chat][DEBUG_FETCH_WRAP] JSON parse failed", e);
          return;
        }'''
    )

    text = text.replace(
        'appendMessage(transcript, "Matilda", reply);',
        '''console.log("[matilda-chat][DEBUG_FETCH_WRAP] final reply:", reply);
        appendMessage(transcript, "Matilda", reply);
        } catch (err) {
          console.error("[matilda-chat][DEBUG_FETCH_WRAP] fetch failed", err);
        }'''
    )

    path.write_text(text)
    print("Injected fetch error visibility wrapper.")
PY

docker compose build dashboard
docker compose up -d dashboard

echo
echo "=== NEXT ==="
echo "Hard refresh → run Quick check → report ALL console logs"
