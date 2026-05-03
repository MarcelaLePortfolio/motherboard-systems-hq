#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/48_live_panel_behavior_audit.txt"

TARGETS=(
  "8131|phase62_agent_pool_beside_metrics"
  "8132|phase65_layout_restore"
  "8133|phase64_4_interactive_baseline"
  "8134|phase96_operator_guidance"
)

fetch() {
  curl -L --max-time 12 "$1" 2>/dev/null || true
}

{
  echo "PHASE 457 - LIVE PANEL BEHAVIOR AUDIT"
  echo "====================================="
  echo
  echo "PURPOSE"
  echo "Determine which authoritative /dashboard.html panels are shell-only versus visibly populated."
  echo
  echo "RULE"
  echo "Audit /dashboard.html only."
  echo
} > "$OUT"

for item in "${TARGETS[@]}"; do
  PORT="${item%%|*}"
  NAME="${item##*|}"

  HTML="$(mktemp)"
  JS="$(mktemp)"
  CORE="$(mktemp)"

  fetch "http://localhost:${PORT}/dashboard.html" > "$HTML"
  fetch "http://localhost:${PORT}/bundle.js" > "$JS"
  fetch "http://localhost:${PORT}/bundle-core.js" > "$CORE"

  {
    echo "===== ${NAME} ====="
    echo "URL=http://localhost:${PORT}/dashboard.html"
    echo

    echo "--- shell sections present ---"
    for marker in \
      "Matilda Chat Console" \
      "Task Delegation" \
      "Recent Tasks" \
      "Task Activity Over Time" \
      "Task Events" \
      "Task History" \
      "Agent Pool" \
      "Atlas Subsystem Status"
    do
      if grep -Fq "$marker" "$HTML"; then
        echo "PRESENT: $marker"
      else
        echo "MISSING: $marker"
      fi
    done
    echo

    echo "--- panel/tab ids present ---"
    for id in \
      op-tab-chat \
      op-tab-delegation \
      obs-tab-recent \
      obs-tab-activity \
      obs-tab-events \
      operator-tabs \
      observational-tabs \
      matilda-chat-root \
      delegation-response \
      delegation-status-panel \
      tasks-widget \
      task-activity-graph \
      mb-task-events-panel-anchor \
      recent-tasks-card \
      task-activity-card \
      task-events-card \
      agent-status-container \
      atlas-status-card
    do
      if grep -Fq "id=\"$id\"" "$HTML"; then
        echo "ID_PRESENT: $id"
      else
        echo "ID_MISSING: $id"
      fi
    done
    echo

    echo "--- likely live endpoints referenced ---"
    grep -Eo '/api/chat|/api/delegate-task|/events/task-events|/events/tasks|/events/ops|/events/reflections' "$JS" "$CORE" 2>/dev/null | sed 's/.*://' | sort -u || true
    echo

    echo "--- matilda wiring proof ---"
    grep -En 'matilda-chat-root|matilda-chat-input|matilda-chat-send|/api/chat|Matilda chat wiring complete' "$JS" | head -n 40 || true
    echo

    echo "--- delegation wiring proof ---"
    grep -En 'delegation-input|delegation-submit|delegation-response|delegation-status-panel|/api/delegate-task|Task Delegation wiring active' "$JS" | head -n 60 || true
    echo

    echo "--- recent tasks / task history proof ---"
    grep -En 'tasks-widget|Recent Tasks|Task History|recent history|recent-history|complete-task-btn|/events/tasks' "$JS" | head -n 80 || true
    echo

    echo "--- task activity proof ---"
    grep -En 'task-activity|Task Activity Over Time|metric-tasks|metric-success|metric-success-rate|metric-latency' "$JS" | head -n 80 || true
    echo

    echo "--- task events proof ---"
    grep -En 'task-events|Task Events|mb-task-events-panel|mb.task.event|/events/task-events' "$JS" | head -n 100 || true
    echo

    echo "--- agent pool / atlas proof ---"
    grep -En 'agent-status-container|Agent Pool|metric-agents|atlas-status|Atlas Subsystem Status|events/ops|events/reflections' "$JS" "$CORE" | head -n 100 || true
    echo

    echo "--- behavior verdict ---"

    if grep -Fq 'matilda-chat-root' "$HTML" && grep -Eq '/api/chat|matilda-chat-send|Matilda chat wiring complete' "$JS"; then
      echo "MATILDA_CHAT=likely wired"
    else
      echo "MATILDA_CHAT=unclear or missing"
    fi

    if grep -Fq 'delegation-submit' "$HTML" && grep -Eq '/api/delegate-task|Task Delegation wiring active' "$JS"; then
      echo "TASK_DELEGATION=likely wired"
    else
      echo "TASK_DELEGATION=unclear or missing"
    fi

    if grep -Fq 'mb-task-events-panel-anchor' "$HTML" && grep -Eq '/events/task-events|mb.task.event|task-events panel mounted' "$JS"; then
      echo "TASK_EVENTS=likely wired"
    else
      echo "TASK_EVENTS=unclear or missing"
    fi

    if grep -Fq 'tasks-widget' "$HTML" && grep -Eq 'tasks-widget|/events/tasks|Recent Tasks' "$JS"; then
      echo "RECENT_TASKS=partially or likely wired"
    else
      echo "RECENT_TASKS=unclear or missing"
    fi

    if grep -Fq 'task-activity-graph' "$HTML" && grep -Eq 'task-activity|Task Activity Over Time|metric-tasks|metric-success|metric-latency' "$JS"; then
      echo "TASK_ACTIVITY=partially or likely wired"
    else
      echo "TASK_ACTIVITY=unclear or missing"
    fi

    if grep -Eq 'Task History|recent history|recent-history' "$JS"; then
      echo "TASK_HISTORY=partially or likely wired"
    else
      echo "TASK_HISTORY=unclear or missing"
    fi

    if grep -Fq 'agent-status-container' "$HTML" && grep -Eq 'agent-status-container|events/ops|events/reflections' "$JS" "$CORE"; then
      echo "AGENT_POOL_AND_SIGNAL_ROW=likely wired"
    else
      echo "AGENT_POOL_AND_SIGNAL_ROW=unclear or missing"
    fi

    echo
  } >> "$OUT"

  rm -f "$HTML" "$JS" "$CORE"
done

{
  echo "NEXT"
  echo "Use this file to identify the first panel that is shell-present but runtime-unclear."
  echo "That panel becomes the next mutation target."
} >> "$OUT"

sed -n '1,360p' "$OUT"
