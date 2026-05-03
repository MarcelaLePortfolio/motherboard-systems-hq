#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/49_observational_task_card_wiring_verification.txt"
TMP_BUNDLE="$(mktemp)"
TMP_DASH="$(mktemp)"

cp public/bundle.js "$TMP_BUNDLE"
cp public/dashboard.html "$TMP_DASH"

{
  echo "PHASE 457 - OBSERVATIONAL TASK CARD WIRING VERIFICATION"
  echo "======================================================="
  echo
  echo "PURPOSE"
  echo "Determine exactly which observational/task card surfaces are:"
  echo "- shell-present"
  echo "- bundle-referenced"
  echo "- event-bound"
  echo "- likely fully wired vs partially wired vs missing"
  echo
  echo "AUTHORITATIVE SURFACE"
  echo "/dashboard.html -> public/dashboard.html"
  echo
  echo "FILES"
  echo "dashboard shell: public/dashboard.html"
  echo "bundle: public/bundle.js"
  echo

  echo "===== SHELL PRESENCE ====="
  for token in \
    "recent-tasks-card" \
    "task-activity-card" \
    "task-events-card" \
    "tasks-widget" \
    "task-activity-graph" \
    "mb-task-events-panel-anchor" \
    "obs-tab-recent" \
    "obs-tab-activity" \
    "obs-tab-events" \
    "observational-tabs" \
    "observational-panels"
  do
    if grep -q "$token" "$TMP_DASH"; then
      echo "SHELL_PRESENT: $token"
    else
      echo "SHELL_MISSING: $token"
    fi
  done
  echo

  echo "===== BUNDLE REFERENCES ====="
  for token in \
    "recent-tasks-card" \
    "task-activity-card" \
    "task-events-card" \
    "tasks-widget" \
    "task-activity-graph" \
    "mb-task-events-panel-anchor" \
    "obs-tab-recent" \
    "obs-tab-activity" \
    "obs-tab-events" \
    "observational-tabs" \
    "observational-panels" \
    "Task Events" \
    "Task History" \
    "Recent Tasks" \
    "Task Activity Over Time"
  do
    if grep -q "$token" "$TMP_BUNDLE"; then
      echo "BUNDLE_REFERENCES: $token"
    else
      echo "BUNDLE_NO_REFERENCE: $token"
    fi
  done
  echo

  echo "===== EVENT / API HOOKS ====="
  for token in \
    "/events/task-events" \
    "/events/tasks" \
    "mb.task.event" \
    "task.created" \
    "task.completed" \
    "task.failed" \
    "EventSource" \
    "tasks-widget" \
    "metric-tasks" \
    "metric-success" \
    "metric-latency"
  do
    if grep -q "$token" "$TMP_BUNDLE"; then
      echo "HOOK_PRESENT: $token"
    else
      echo "HOOK_MISSING: $token"
    fi
  done
  echo

  echo "===== PROBABLE DOM TARGETING LINES ====="
  grep -nE \
    'recent-tasks-card|task-activity-card|task-events-card|tasks-widget|task-activity-graph|mb-task-events-panel-anchor|obs-tab-recent|obs-tab-activity|obs-tab-events|observational-tabs|mb\.task\.event|/events/task-events|/events/tasks|metric-tasks|metric-success|metric-latency' \
    "$TMP_BUNDLE" | sed -n '1,220p' || true
  echo

  echo "===== VERDICT ====="

  recent_shell=0
  recent_bundle=0
  history_bundle=0
  activity_shell=0
  activity_bundle=0
  events_shell=0
  events_bundle=0

  grep -q 'tasks-widget' "$TMP_DASH" && recent_shell=1 || true
  grep -q 'tasks-widget' "$TMP_BUNDLE" && recent_bundle=1 || true

  grep -q 'Task History' "$TMP_DASH" && true || true
  grep -q 'Task History' "$TMP_BUNDLE" && history_bundle=1 || true

  grep -q 'task-activity-card' "$TMP_DASH" && activity_shell=1 || true
  grep -q 'task-activity-graph' "$TMP_DASH" && activity_shell=1 || true
  grep -q 'task-activity-card' "$TMP_BUNDLE" && activity_bundle=1 || true
  grep -q 'task-activity-graph' "$TMP_BUNDLE" && activity_bundle=1 || true
  grep -q 'metric-tasks' "$TMP_BUNDLE" && activity_bundle=1 || true

  grep -q 'task-events-card' "$TMP_DASH" && events_shell=1 || true
  grep -q 'mb-task-events-panel-anchor' "$TMP_DASH" && events_shell=1 || true
  grep -q '/events/task-events' "$TMP_BUNDLE" && events_bundle=1 || true
  grep -q 'mb.task.event' "$TMP_BUNDLE" && events_bundle=1 || true

  if [ "$recent_shell" -eq 1 ] && [ "$recent_bundle" -eq 1 ]; then
    echo "RECENT_TASKS=present_in_shell_and_bundle (likely wired or partially wired)"
  elif [ "$recent_shell" -eq 1 ]; then
    echo "RECENT_TASKS=shell_only (likely unwired)"
  else
    echo "RECENT_TASKS=missing_from_shell"
  fi

  if [ "$history_bundle" -eq 1 ]; then
    echo "TASK_HISTORY=bundle_reference_present"
  else
    echo "TASK_HISTORY=no_bundle_reference_detected"
  fi

  if [ "$activity_shell" -eq 1 ] && [ "$activity_bundle" -eq 1 ]; then
    echo "TASK_ACTIVITY=present_in_shell_and_bundle (likely partial_or_metric_backed)"
  elif [ "$activity_shell" -eq 1 ]; then
    echo "TASK_ACTIVITY=shell_only (likely unwired)"
  else
    echo "TASK_ACTIVITY=missing_from_shell"
  fi

  if [ "$events_shell" -eq 1 ] && [ "$events_bundle" -eq 1 ]; then
    echo "TASK_EVENTS=present_in_shell_and_bundle (likely wired)"
  elif [ "$events_shell" -eq 1 ]; then
    echo "TASK_EVENTS=shell_only (likely unwired)"
  else
    echo "TASK_EVENTS=missing_from_shell"
  fi
  echo

  echo "NEXT SAFE INTERPRETATION"
  echo "- If TASK_EVENTS is wired while RECENT_TASKS / TASK_ACTIVITY / TASK_HISTORY are weaker,"
  echo "  then the event stream survived and only observational consumer mounts need repair."
  echo "- If all cards are shell-present but only Task Events has concrete event hooks,"
  echo "  then the observational/task card problem is a UI-consumer reattachment gap, not system loss."
} > "$OUT"

rm -f "$TMP_BUNDLE" "$TMP_DASH"

sed -n '1,320p' "$OUT"
