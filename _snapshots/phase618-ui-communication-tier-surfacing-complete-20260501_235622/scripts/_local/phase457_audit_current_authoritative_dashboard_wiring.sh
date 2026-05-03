#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/47_current_authoritative_dashboard_wiring_audit.txt"

TARGETS=(
  "8131|phase62_agent_pool_beside_metrics"
  "8132|phase65_layout_restore"
  "8133|phase64_4_interactive_baseline"
  "8134|phase96_operator_guidance"
)

fetch_body() {
  local url="$1"
  curl -L --max-time 10 "$url" 2>/dev/null || true
}

{
  echo "PHASE 457 - CURRENT AUTHORITATIVE DASHBOARD WIRING AUDIT"
  echo "========================================================"
  echo
  echo "PURPOSE"
  echo "Determine what is currently wired in the authoritative dashboard shell at /dashboard.html."
  echo
  echo "RULE"
  echo "Audit /dashboard.html, not /"
  echo
} > "$OUT"

for item in "${TARGETS[@]}"; do
  PORT="${item%%|*}"
  NAME="${item##*|}"

  ROOT_HTML="$(mktemp)"
  DASH_HTML="$(mktemp)"
  BUNDLE_JS="$(mktemp)"
  BUNDLE_CORE="$(mktemp)"

  fetch_body "http://localhost:${PORT}/" > "$ROOT_HTML"
  fetch_body "http://localhost:${PORT}/dashboard.html" > "$DASH_HTML"
  fetch_body "http://localhost:${PORT}/bundle.js" > "$BUNDLE_JS"
  fetch_body "http://localhost:${PORT}/bundle-core.js" > "$BUNDLE_CORE"

  {
    echo "===== ${NAME} ====="
    echo "ROOT_URL=http://localhost:${PORT}/"
    echo "DASH_URL=http://localhost:${PORT}/dashboard.html"
    echo
    echo "--- root vs dashboard hashes ---"
    [ -s "$ROOT_HTML" ] && { printf "root: "; shasum -a 256 "$ROOT_HTML"; } || echo "root: MISSING"
    [ -s "$DASH_HTML" ] && { printf "dashboard: "; shasum -a 256 "$DASH_HTML"; } || echo "dashboard: MISSING"
    echo
    echo "--- dashboard title ---"
    grep -o '<title>[^<]*</title>' "$DASH_HTML" | head -n 1 || true
    echo
    echo "--- dashboard shell markers ---"
    grep -Eo 'operator-tabs|observational-tabs|phase61-workspace-grid|phase62-top-row|operator-workspace-card|observational-workspace-card|Agent Pool|Atlas Subsystem Status|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Task Events|Task History|Project Visual Output|Critical Ops Alerts|System Reflections|output-display' "$DASH_HTML" | sort -u || true
    echo
    echo "--- tab/button/container ids from dashboard.html ---"
    grep -Eo 'id="[^"]+"' "$DASH_HTML" | sed 's/id="//; s/"$//' | grep -Ei 'operator|observ|task|history|event|deleg|matilda|agent|atlas|metric|telemetry|tab|workspace' | sort -u || true
    echo
    echo "--- script references in dashboard.html ---"
    grep -Eo '<script[^>]+src="[^"]+"' "$DASH_HTML" | sed -E 's/.*src="([^"]+)".*/\1/' | sort -u || true
    echo
    echo "--- bundle.js wiring signals ---"
    grep -Eo 'operator-tabs|observational-tabs|phase61-workspace-grid|phase62-top-row|Task Events|Task History|Recent Tasks|Task Activity Over Time|Task Delegation|Matilda Chat Console|Agent Pool|Atlas Subsystem Status|events/ops|events/reflections|events/task-events|events/tasks|EventSource|task-events|recent history|recent-history|agent activity|agent pool|operator guidance|guidance|telemetry' "$BUNDLE_JS" | sort -u || true
    echo
    echo "--- bundle-core.js wiring signals ---"
    grep -Eo 'events/ops|events/reflections|events/task-events|events/tasks|EventSource|task-events|recent history|recent-history|agent activity|agent pool|telemetry|guidance' "$BUNDLE_CORE" | sort -u || true
    echo
    echo "--- bundle.js probable task/observational mounts ---"
    grep -En 'task-events|Task Events|Task History|Recent Tasks|Task Activity Over Time|recent-history|recent history|observational-tabs|operator-tabs|delegation|matilda|agent pool|telemetry' "$BUNDLE_JS" | head -n 80 || true
    echo
    echo "--- bundle-core.js probable runtime mounts ---"
    grep -En 'events/ops|events/reflections|events/task-events|events/tasks|EventSource|telemetry|task-events' "$BUNDLE_CORE" | head -n 80 || true
    echo
  } >> "$OUT"

  rm -f "$ROOT_HTML" "$DASH_HTML" "$BUNDLE_JS" "$BUNDLE_CORE"
done

{
  echo "INTERPRETATION GUIDE"
  echo "- Items present in dashboard shell markers exist visually in /dashboard.html."
  echo "- Script references show which files the shell loads directly."
  echo "- Bundle wiring signals show what the shipped JS appears to mount or subscribe to."
  echo "- Missing task container ids or absent task-events/task-history strings likely indicate unwired or partially wired task surfaces."
} >> "$OUT"

sed -n '1,360p' "$OUT"
