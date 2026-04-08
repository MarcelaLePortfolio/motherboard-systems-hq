#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/54_live_remaining_ui_gaps_audit.txt"
TMP_BUNDLE="$(mktemp)"
TMP_CORE="$(mktemp)"
TMP_DASH="$(mktemp)"

cp public/bundle.js "$TMP_BUNDLE"
cp public/bundle-core.js "$TMP_CORE"
cp public/dashboard.html "$TMP_DASH"

{
  echo "PHASE 457 - LIVE REMAINING UI GAPS AUDIT"
  echo "========================================"
  echo
  echo "PURPOSE"
  echo "Pinpoint the exact shipped sources behind:"
  echo "- probe:recent:error: column \"updated_at\" does not exist"
  echo "- probe:history:loading"
  echo "- empty Task Events panel"
  echo "- Operator Guidance confidence showing unknown"
  echo
  echo "===== DASHBOARD SCRIPT TAGS ====="
  grep -n '<script' "$TMP_DASH" || true
  echo
  echo "===== UPDATED_AT / RECENT / HISTORY PROBE SOURCES ====="
  grep -RIn --exclude-dir=.git --exclude="$OUT" \
    -E 'updated_at|probe:recent|probe:history|recentLogs|tasks-widget|recent history|task history|history:loading|recent:error' \
    public server scripts 2>/dev/null || true
  echo
  echo "===== TASK EVENTS SOURCES ====="
  grep -RIn --exclude-dir=.git --exclude="$OUT" \
    -E 'task-events|mb.task.event|events/task-events|task\.created|task\.completed|task\.failed|mb-task-events-panel-anchor|Task Events' \
    public server scripts 2>/dev/null || true
  echo
  echo "===== OPERATOR GUIDANCE / CONFIDENCE SOURCES ====="
  grep -RIn --exclude-dir=.git --exclude="$OUT" \
    -E 'Operator Guidance|Guidance stream active|Confidence:|confidence|Sources:|system-health|operator guidance|guidance stream' \
    public server scripts 2>/dev/null || true
  echo
  echo "===== BUNDLE HOTSPOTS ====="
  grep -nE 'updated_at|probe:recent|probe:history|recentLogs|tasks-widget|task-events|mb.task.event|Confidence:|Guidance stream active|operator guidance|system-health' "$TMP_BUNDLE" || true
  echo
  echo "===== BUNDLE-CORE HOTSPOTS ====="
  grep -nE 'updated_at|probe:recent|probe:history|recentLogs|tasks-widget|task-events|mb.task.event|Confidence:|Guidance stream active|operator guidance|system-health' "$TMP_CORE" || true
  echo
  echo "===== QUICK VERDICT ====="
  recent_probe=0
  history_probe=0
  task_events_consumer=0
  guidance_confidence=0

  grep -Rqs 'updated_at' public server scripts && recent_probe=1 || true
  grep -Rqs 'probe:history' public server scripts && history_probe=1 || true
  grep -Rqs 'mb.task.event' public server scripts && task_events_consumer=1 || true
  grep -Rqs 'Confidence:' public server scripts && guidance_confidence=1 || true

  echo "RECENT_PROBE_SOURCE=$recent_probe"
  echo "HISTORY_PROBE_SOURCE=$history_probe"
  echo "TASK_EVENTS_CONSUMER_SOURCE=$task_events_consumer"
  echo "GUIDANCE_CONFIDENCE_SOURCE=$guidance_confidence"
  echo
  echo "NEXT"
  echo "Patch only the proven sources from this audit:"
  echo "1. eliminate updated_at assumption in recent/history probe path"
  echo "2. ensure restored task panels own recent/history rendering without stale probe output"
  echo "3. verify task-events consumer mounts into current observational shell"
  echo "4. restore confidence label derivation in operator guidance panel"
} > "$OUT"

rm -f "$TMP_BUNDLE" "$TMP_CORE" "$TMP_DASH"

sed -n '1,260p' "$OUT"
