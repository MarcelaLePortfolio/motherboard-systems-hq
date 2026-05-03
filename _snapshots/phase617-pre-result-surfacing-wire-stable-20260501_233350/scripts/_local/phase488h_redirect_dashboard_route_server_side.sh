#!/bin/bash
set -euo pipefail

git checkout -- public/dashboard.html || true

python3 << 'PY'
from pathlib import Path

path = Path("server.mjs")
text = path.read_text()

old = 'app.get("/dashboard", (req, res) => res.sendFile(path.join(__dirname, "public", "dashboard.html")));\napp.get("/", (req, res) => res.redirect("/dashboard"));\n'
new = 'app.get("/dashboard", (req, res) => res.redirect("/"));\napp.get("/", (req, res) => res.sendFile(path.join(__dirname, "public", "index.html")));\n'

if old not in text:
    raise SystemExit("Expected dashboard/root route block not found exactly; aborting.")

path.write_text(text.replace(old, new, 1))
print("Patched server routes: /dashboard -> / and / serves canonical index.html")
PY

docker compose build dashboard
docker compose up -d dashboard
sleep 3

echo "=== VERIFY ROOT ==="
curl -sS http://127.0.0.1:8080/ | grep -n '<title>\|matilda-chat-root\|Operator Workspace\|Telemetry Console' | head -n 20 || true

echo
echo "=== VERIFY /DASHBOARD REDIRECT ==="
curl -I -sS http://127.0.0.1:8080/dashboard | head -n 20 || true

git add server.mjs public/dashboard.html
git commit -m "Make root canonical and redirect dashboard route server-side"
git push
