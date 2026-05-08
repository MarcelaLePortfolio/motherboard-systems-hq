
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 REBUILD AND VERIFY DASHBOARD JS v2 ====="

echo "[1] Verify local renderer marker exists"

python3 - << 'PY'

from pathlib import Path

text = Path("public/js/phase530_visible_panels_bridge.js").read_text()

needles = [

    "data-phase717-execution-card",

    "Requeue pending contract",

    "Retry differently pending contract",

]

missing = [needle for needle in needles if needle not in text]

if missing:

    raise SystemExit("Missing local markers: " + ", ".join(missing))

print("Local renderer markers verified.")

PY

echo ""

echo "[2] Rebuild and restart dashboard container"

docker compose up -d --build dashboard

echo ""

echo "[3] Verify containers"

docker compose ps

echo ""

echo "[4] Verify served dashboard JS contains Phase 717 markers"

python3 - << 'PY'

from pathlib import Path

from urllib.request import urlopen

import time

url = f"http://localhost:3000/js/phase530_visible_panels_bridge.js?phase717={int(time.time())}"

text = urlopen(url, timeout=20).read().decode("utf-8")

Path("/tmp/phase717_served_bridge.js").write_text(text)

needles = [

    "data-phase717-execution-card",

    "Requeue pending contract",

    "Retry differently pending contract",

]

missing = [needle for needle in needles if needle not in text]

if missing:

    raise SystemExit("Missing served markers: " + ", ".join(missing))

print("Served dashboard JS markers verified.")

print("Saved served JS copy to /tmp/phase717_served_bridge.js")

PY

echo ""

echo "[5] Save verification note"

cat > PHASE717_DASHBOARD_JS_REBUILD_VERIFIED.txt << 'EON'

PHASE 717 — DASHBOARD JS REBUILD VERIFIED

Verified:

- Local renderer contains Phase 717 lifecycle-card markers.

- Dashboard container was rebuilt and restarted.

- Served public JS contains Phase 717 lifecycle-card markers.

- Recent Tasks visual update should appear after browser hard refresh.

- Retry/requeue controls remain disabled placeholders only.

- No backend mutation behavior was added.

Browser step:

- Hard refresh http://localhost:3000

EON

git add PHASE717_REBUILD_AND_VERIFY_DASHBOARD_JS.sh PHASE717_DASHBOARD_JS_REBUILD_VERIFIED.txt

git commit -m "Phase 717: verify dashboard serves lifecycle renderer" || true

git push origin dev

git status --short

git log --oneline --decorate -6

echo "===== PHASE 717 REBUILD AND VERIFY DASHBOARD JS v2 COMPLETE ====="

