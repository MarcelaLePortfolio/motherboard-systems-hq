#!/bin/bash
set -euo pipefail

python3 << 'PY'
from pathlib import Path

path = Path("public/js/matilda-chat-console.js")
text = path.read_text()

# Inject debug logs into handleSend
if "[matilda-chat][DEBUG]" in text:
    print("Debug logging already present.")
else:
    text = text.replace(
        'async function handleSend() {',
        '''async function handleSend() {
      console.log("[matilda-chat][DEBUG] handleSend triggered");'''
    )

    text = text.replace(
        'var res = await fetch("/api/chat", {',
        '''console.log("[matilda-chat][DEBUG] sending request to /api/chat");
        var res = await fetch("/api/chat", {'''
    )

    text = text.replace(
        'var data = await res.json();',
        '''var data = await res.json();
        console.log("[matilda-chat][DEBUG] response received:", data);'''
    )

    text = text.replace(
        'appendMessage(transcript, "Matilda", reply);',
        '''console.log("[matilda-chat][DEBUG] appending reply:", reply);
        appendMessage(transcript, "Matilda", reply);'''
    )

    path.write_text(text)
    print("Injected debug logging into matilda-chat-console.js")
PY

docker compose build dashboard
docker compose up -d dashboard

echo
echo "=== NEXT STEP ==="
echo "Open browser dev console (Cmd+Option+J), click Quick check, and report logs."
