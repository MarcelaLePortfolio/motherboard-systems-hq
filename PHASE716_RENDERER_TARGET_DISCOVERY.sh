
#!/bin/bash

set -u

OUT="phase716_renderer_target_discovery.txt"

: > "$OUT"

{

  echo "===== PHASE 716 RENDERER TARGET DISCOVERY ====="

  echo ""

  echo "[1] Confirm stable base"

  git checkout dev

  git status --short

  git log --oneline -8

  echo ""

  echo "[2] Locate exact renderer files for Recent Tasks / Execution Inspector tabs"

  grep -RniE "Recent Tasks|Task History|Execution Inspector|recentTasks|recentLogs|obs-panel-recent|observational-panels|phase530_visible_panels_bridge|phase573_execution_inspector_debug" public app server 2>/dev/null || true

  echo ""

  echo "[3] Read likely renderer files"

  for f in \

    public/phase530_visible_panels_bridge.js \

    public/phase573_execution_inspector_debug.js \

    public/js/dashboard-tasks-widget.js \

    public/dashboard.js \

    public/dashboard-logs.js \

    public/dashboard-status.js

  do

    if [ -f "$f" ]; then

      echo ""

      echo "----- $f -----"

      sed -n '1,260p' "$f" || true

    fi

  done

  echo ""

  echo "[4] Confirm no broad failed overflow CSS is present"

  grep -Rni "phase716_zero_height_recent_tasks_fix.css\|phase716_execution_inspector_containment.css\|phase716-execution-inspector-overflow.css" public 2>/dev/null || true

  echo ""

  echo "===== PHASE 716 RENDERER TARGET DISCOVERY COMPLETE ====="

} | tee "$OUT"

