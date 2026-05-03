#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/40_tabbed_workspace_shell_search.txt"

{
  echo "PHASE 457 - TABBED WORKSPACE SHELL SEARCH"
  echo "========================================="
  echo
  echo "PURPOSE"
  echo "Find commits that match the remembered dashboard shell markers:"
  echo "- Matilda Chat + Delegation share one card via tabs"
  echo "- Task panels share one card via tabs"
  echo "- Agent Pool shares top row with telemetry"
  echo "- Output display panel removed"
  echo
  echo "SEARCH 1 - HIGH SIGNAL COMMIT MESSAGES"
  git log --all --oneline --decorate -- \
    public/index.html \
    public/dashboard.html \
    public/css \
    public/js \
  | grep -Ei 'phase 61|phase 62|phase 63|phase 64|workspace|tabs|tabbed|consolidat|operator column|observational|agent pool|metrics|atlas|output|remove|redundant|history|recent tasks|task history' || true
  echo
  echo "SEARCH 2 - HTML HISTORY FOR TABBED WORKSPACE IDS / STRINGS"
  git log --all -S'operator-tabs' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'observational-tabs' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'phase61-workspace-grid' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'phase62-top-row' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'Matilda Chat Console' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'Task Delegation' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'Recent Tasks' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'Task Activity Over Time' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  echo "SEARCH 3 - NEGATIVE FILTERS FOR OLDER SHELLS"
  git log --all -S'Output Display' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'Critical Ops Alerts' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  git log --all -S'System Reflections' --oneline --decorate -- public/index.html public/dashboard.html public/js public/css || true
  echo
  echo "SEARCH 4 - TOP CANDIDATE FILE TOUCHES"
  git log --all --oneline --decorate -- \
    public/index.html \
    public/dashboard.html \
    public/css/phase61_workspace_consolidation.css \
    public/css/phase61_tabs_observational_workspace.css \
    public/js/phase61_tabs_workspace.js \
    public/js/dashboard-bundle-entry.js \
    public/js/agent-status-row.js \
    public/js/phase61_recent_history_wire.js \
    public/js/phase64_agent_activity_bootstrap.js \
    public/js/task-events-sse-client.js || true
  echo
  echo "NEXT"
  echo "Use the resulting candidate SHAs to boot only the commits that prove tabbed shared cards and shared top-row layout."
} > "$OUT"

sed -n '1,320p' "$OUT"
