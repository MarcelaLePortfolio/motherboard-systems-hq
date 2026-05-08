
#!/bin/bash

set -u

echo "===== PHASE 716 SAFE LIVE DASHBOARD DOM INSPECTION ====="

OUT="phase716_live_dashboard_dom_safe.txt"

: > "$OUT"

{

  echo "[1] Branch + clean state"

  git branch --show-current

  git status --short

  git log --oneline -8

  echo ""

  echo "[2] Served root HTML inspector/advanced/task snippets"

  curl -sS "http://localhost:3000/" > /tmp/phase716_served_root.html

  grep -ni -A60 -B30 "Execution Inspector" /tmp/phase716_served_root.html || true

  grep -ni -A60 -B30 "Advanced" /tmp/phase716_served_root.html || true

  grep -ni -A60 -B30 "JSON" /tmp/phase716_served_root.html || true

  grep -ni -A60 -B30 "recent tasks" /tmp/phase716_served_root.html || true

  echo ""

  echo "[3] Dashboard JS inspector/advanced/task snippets"

  grep -Rni -A40 -B20 "Execution Inspector\|Advanced\|JSON\|recent tasks\|task-events\|task card" public/js public/scripts public/*.js 2>/dev/null || true

  echo ""

  echo "[4] Dashboard CSS layout snippets"

  grep -Rni -A30 -B15 "Execution Inspector\|advanced\|json\|pre\|task-card\|recent-task\|overflow\|z-index\|position" public/css public/*.css 2>/dev/null || true

  echo ""

  echo "===== PHASE 716 SAFE LIVE DASHBOARD DOM INSPECTION COMPLETE ====="

} | tee "$OUT"

git status --short

