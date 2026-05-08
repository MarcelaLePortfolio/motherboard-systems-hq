
#!/bin/bash

set -u

echo "===== PHASE 716 FIX ZERO-HEIGHT RECENT TASKS CHAIN ====="

cat > public/css/phase716_zero_height_recent_tasks_fix.css << 'CSS'

/*

 * Phase 716 — Recent Tasks zero-height containment fix

 * Evidence: live DOM showed #recent-tasks-card, #obs-panel-recent, and #observational-panels at height: 0,

 * causing Recent Tasks / expanded evidence content to visually escape into following content.

 * Scope: UI layout only. No task creation, mutation, retry, worker, DB, SSE, or advisory behavior changes.

 */

#phase61-telemetry-column,

#observational-workspace-card,

#observational-panels,

#obs-panel-recent,

#recent-tasks-card {

  height: auto !important;

  max-height: none !important;

}

#observational-panels,

#obs-panel-recent,

#recent-tasks-card {

  min-height: fit-content !important;

  overflow: visible !important;

}

#obs-panel-recent.active {

  display: block !important;

}

#recent-tasks-card {

  display: block !important;

}

#recentTasks,

#recentLogs {

  max-height: 18rem !important;

  overflow: auto !important;

  white-space: normal !important;

}

CSS

python3 - << 'PY'

from pathlib import Path

link = '<link rel="stylesheet" href="css/phase716_zero_height_recent_tasks_fix.css" />'

targets = [Path("public/index.html"), Path("public/dashboard.html")]

for path in targets:

    if not path.exists():

        continue

    html = path.read_text(errors="ignore")

    html = html.replace(link, "")

    marker = '<link rel="stylesheet" href="css/phase491_workspace_equal_height.css" />'

    if marker in html:

        html = html.replace(marker, marker + "\n  " + link, 1)

    elif "</head>" in html:

        html = html.replace("</head>", "  " + link + "\n</head>", 1)

    else:

        html = link + "\n" + html

    path.write_text(html)

    print(f"patched {path}")

PY

echo ""

echo "[1] Confirm source patch"

grep -n "phase716_zero_height_recent_tasks_fix.css" public/index.html public/dashboard.html || true

grep -n "zero-height\|recent-tasks-card\|obs-panel-recent\|observational-panels" public/css/phase716_zero_height_recent_tasks_fix.css || true

echo ""

echo "[2] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[3] Confirm runtime"

docker compose ps

echo ""

echo "[4] Confirm served root includes CSS"

curl -sS "http://localhost:3000/" | grep -n "phase716_zero_height_recent_tasks_fix.css" || true

echo ""

echo "[5] Confirm CSS asset serves"

curl -sS -i "http://localhost:3000/css/phase716_zero_height_recent_tasks_fix.css" | head -40 || true

echo ""

echo "[6] Confirm APIs"

curl -sS -i "http://localhost:3000/api/tasks" | head -30 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -25 || true

echo ""

echo "[7] Git status"

git status --short

echo "===== PHASE 716 ZERO-HEIGHT RECENT TASKS FIX COMPLETE ====="

