#!/bin/bash
set -euo pipefail

python3 << 'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()

bundle_tag = '<script type="module" src="js/dashboard-bundle-entry.js"></script>'

if bundle_tag in text:
    print("dashboard bundle already present")
else:
    marker = "</body>"
    if marker not in text:
        raise SystemExit("Missing </body> in dashboard.html")

    text = text.replace(marker, f'  {bundle_tag}\n{marker}', 1)
    path.write_text(text)
    print("Injected dashboard bundle into dashboard.html")
PY

docker compose build dashboard
docker compose up -d dashboard

echo
echo "=== verify dashboard scripts ==="
curl -sS http://127.0.0.1:8080/dashboard | grep -n 'dashboard-bundle-entry\|matilda-chat-console' | head -n 20
