#!/bin/bash
set -euo pipefail

python3 << 'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()

script_tag = '  <script defer src="js/matilda-chat-console.js"></script>\n'

if 'src="js/matilda-chat-console.js"' in text:
    print("matilda-chat-console.js script tag already present in public/dashboard.html")
else:
    marker = "</body>"
    if marker not in text:
        raise SystemExit("Missing </body> in public/dashboard.html; aborting.")
    text = text.replace(marker, script_tag + marker, 1)
    path.write_text(text)
    print("Injected matilda-chat-console.js script tag into public/dashboard.html")
PY

docker compose build dashboard
docker compose up -d dashboard

printf '\n=== /dashboard script refs ===\n'
curl -sS http://127.0.0.1:8080/dashboard | grep -n 'matilda-chat-console' | head -n 20
