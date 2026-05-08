
#!/bin/bash

set -u

echo "===== PHASE 716 FIX CSS LINK INJECTION ====="

python3 - << 'PY'

from pathlib import Path

path = Path("public/dashboard.html")

html = path.read_text()

link = '<link rel="stylesheet" href="css/phase716-execution-inspector-overflow.css" />'

html = html.replace(link + " -->", "")

html = html.replace("<!-- " + link + " -->", "")

html = html.replace(link, "")

marker = '<link rel="stylesheet" href="css/dashboard-reflections.css" />'

if marker in html:

    html = html.replace(marker, marker + "\n  " + link, 1)

else:

    html = html.replace("</head>", "  " + link + "\n</head>", 1)

path.write_text(html)

PY

echo ""

echo "[1] Confirm real, uncommented CSS link"

grep -n "phase716-execution-inspector-overflow.css" public/dashboard.html

echo ""

echo "[2] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[3] Confirm containers"

docker compose ps

echo ""

echo "[4] Verify dashboard serves CSS link"

curl -sS "http://localhost:3000/" | grep -n "phase716-execution-inspector-overflow.css" || true

echo ""

echo "[5] Verify CSS asset serves"

curl -sS -i "http://localhost:3000/css/phase716-execution-inspector-overflow.css" | head -40 || true

echo ""

echo "[6] Final git status"

git status --short

echo ""

echo "===== PHASE 716 CSS LINK INJECTION FIX COMPLETE ====="

