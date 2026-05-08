
#!/bin/bash

set -u

echo "===== PHASE 716 TRACE + FORCE SERVE CSS LINK ====="

CSS_LINK='<link rel="stylesheet" href="css/phase716-execution-inspector-overflow.css" />'

echo ""

echo "[1] Local branch + status"

git branch --show-current

git status --short

git log --oneline -5

echo ""

echo "[2] Local dashboard candidates containing operator console title"

grep -Rli "Motherboard Systems Operator Console" public 2>/dev/null || true

echo ""

echo "[3] Local CSS link locations"

grep -Rni "phase716-execution-inspector-overflow.css" public 2>/dev/null || true

echo ""

echo "[4] Container dashboard candidates"

docker compose exec -T dashboard sh -lc 'grep -Rli "Motherboard Systems Operator Console" /app/public 2>/dev/null || true'

echo ""

echo "[5] Container CSS link locations before force patch"

docker compose exec -T dashboard sh -lc 'grep -Rni "phase716-execution-inspector-overflow.css" /app/public 2>/dev/null || true'

echo ""

echo "[6] Force patch every local public HTML dashboard/operator console entrypoint"

python3 - << 'PY'

from pathlib import Path

link = '<link rel="stylesheet" href="css/phase716-execution-inspector-overflow.css" />'

targets = []

for path in Path("public").glob("*.html"):

    text = path.read_text(errors="ignore")

    if "Motherboard Systems Operator Console" in text or "Execution Inspector" in text or "Recent Tasks" in text:

        targets.append(path)

if not targets:

    targets = [Path("public/dashboard.html")]

for path in targets:

    text = path.read_text(errors="ignore")

    text = text.replace(link + " -->", "")

    text = text.replace("<!-- " + link + " -->", "")

    text = text.replace(link, "")

    if "</head>" in text:

        text = text.replace("</head>", "  " + link + "\n</head>", 1)

    else:

        text = link + "\n" + text

    path.write_text(text)

    print(f"patched {path}")

PY

echo ""

echo "[7] Confirm local patch"

grep -Rni "phase716-execution-inspector-overflow.css" public/*.html 2>/dev/null || true

echo ""

echo "[8] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[9] Confirm containers"

docker compose ps

echo ""

echo "[10] Container CSS link locations after rebuild"

docker compose exec -T dashboard sh -lc 'grep -Rni "phase716-execution-inspector-overflow.css" /app/public 2>/dev/null || true'

echo ""

echo "[11] Verify served root includes CSS link"

curl -sS "http://localhost:3000/" | grep -n "phase716-execution-inspector-overflow.css" || true

echo ""

echo "[12] Verify CSS asset still serves"

curl -sS -i "http://localhost:3000/css/phase716-execution-inspector-overflow.css" | head -30 || true

echo ""

echo "[13] Final status"

git status --short

echo ""

echo "===== PHASE 716 TRACE + FORCE SERVE CSS LINK COMPLETE ====="

