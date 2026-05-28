
#!/usr/bin/env bash

set -euo pipefail

REPORT="LATEST_DASHBOARD_UI_SURFACE_RECOVERY.txt"

{

  echo "===== LATEST DASHBOARD UI SURFACE RECOVERY ====="

  date

  echo

  echo "===== CURRENT BRANCH ====="

  git branch --show-current

  echo

  echo "===== RECENT DASHBOARD.HTML COMMITS ====="

  git log --oneline --follow -- public/dashboard.html | head -40

  echo

  echo "===== RECENT BUNDLE ENTRY COMMITS ====="

  git log --oneline --follow -- public/js/dashboard-bundle-entry.js | head -40

  echo

  echo "===== RECENT DASHBOARD CSS COMMITS ====="

  git log --oneline --follow -- public/css/dashboard.css | head -40

  echo

  echo "===== SEARCHING FOR NEWER DASHBOARD VARIANTS ====="

  find public -iname '*dashboard*' | sort

  echo

  echo "===== SEARCHING FOR PHASE BACKUPS ====="

  find . -iname '*dashboard*.backup*' -o -iname '*dashboard*.bak*' -o -iname '*dashboard*.old*' -o -iname '*dashboard*.phase*'

  echo

  echo "===== CURRENT DASHBOARD TITLE ====="

  grep -n "<title" public/dashboard.html || true

  echo

  echo "===== CURRENT DASHBOARD AGENT SURFACE ====="

  grep -n "agent-status-container" public/dashboard.html || true

  echo

  echo "===== CURRENT DASHBOARD TASK SURFACE ====="

  grep -n "tasks-widget" public/dashboard.html || true

  echo

  echo "===== CURRENT DASHBOARD METRIC SURFACE ====="

  grep -n "metric-" public/dashboard.html | head -40 || true

  echo

} | tee "$REPORT"

echo

echo "REPORT WRITTEN: $REPORT"

