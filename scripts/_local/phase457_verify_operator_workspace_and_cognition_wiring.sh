#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/51_operator_workspace_and_cognition_wiring_verification.txt"
TMP_DASH="$(mktemp)"
TMP_BUNDLE="$(mktemp)"
TMP_CORE="$(mktemp)"

cp public/dashboard.html "$TMP_DASH"
cp public/bundle.js "$TMP_BUNDLE"
cp public/bundle-core.js "$TMP_CORE"

{
  echo "PHASE 457 - OPERATOR WORKSPACE AND COGNITION WIRING VERIFICATION"
  echo "================================================================"
  echo
  echo "PURPOSE"
  echo "Determine whether the operator workspace, cognition-facing streams, and governance-adjacent"
  echo "dashboard consumers are still present in the authoritative shell and shipped bundles."
  echo
  echo "AUTHORITATIVE SURFACE"
  echo "/dashboard.html -> public/dashboard.html"
  echo
  echo "FILES"
  echo "dashboard shell: public/dashboard.html"
  echo "bundle: public/bundle.js"
  echo "bundle-core: public/bundle-core.js"
  echo

  echo "===== SHELL PRESENCE ====="
  for token in \
    operator-tabs \
    operator-panels \
    operator-workspace-card \
    op-tab-chat \
    op-tab-delegation \
    op-panel-delegation \
    matilda-chat-root \
    matilda-chat-input \
    matilda-chat-send \
    matilda-chat-transcript \
    delegation-input \
    delegation-submit \
    delegation-response \
    delegation-status-panel \
    agent-status-container \
    atlas-status-card \
    atlas-status-details \
    metric-agents \
    metric-tasks \
    metric-latency \
    metric-success \
    metric-success-rate \
    obs-tab-recent \
    obs-tab-activity \
    obs-tab-events
  do
    if grep -q "$token" "$TMP_DASH"; then
      echo "SHELL_PRESENT: $token"
    else
      echo "SHELL_MISSING: $token"
    fi
  done
  echo

  echo "===== HUMAN-VISIBLE SECTION LABELS ====="
  grep -Eo 'Matilda Chat Console|Task Delegation|Agent Pool|Atlas Subsystem Status|Recent Tasks|Task Activity Over Time|Task Events|Task History' "$TMP_DASH" | sort -u || true
  echo

  echo "===== OPERATOR / COGNITION / GOVERNANCE BUNDLE REFERENCES ====="
  for token in \
    "matilda-chat-root" \
    "matilda-chat-input" \
    "matilda-chat-send" \
    "delegation-input" \
    "delegation-submit" \
    "delegation-response" \
    "delegation-status-panel" \
    "/api/chat" \
    "/api/delegate-task" \
    "/events/ops" \
    "/events/reflections" \
    "/events/task-events" \
    "/events/tasks" \
    "EventSource" \
    "mb:ops:update" \
    "ops.state" \
    "reflections" \
    "operator guidance" \
    "guidance" \
    "agent-status-container" \
    "metric-agents" \
    "metric-tasks" \
    "metric-latency" \
    "metric-success" \
    "metric-success-rate"
  do
    if grep -qi "$token" "$TMP_BUNDLE" || grep -qi "$token" "$TMP_CORE"; then
      echo "BUNDLE_REFERENCES: $token"
    else
      echo "BUNDLE_NO_REFERENCE: $token"
    fi
  done
  echo

  echo "===== PROBABLE DOM TARGETING / LIVE WIRING LINES ====="
  grep -En 'matilda-chat-root|matilda-chat-input|matilda-chat-send|matilda-chat-transcript|delegation-input|delegation-submit|delegation-response|delegation-status-panel|/api/chat|/api/delegate-task|/events/ops|/events/reflections|ops.state|mb:ops:update|agent-status-container|metric-agents|metric-tasks|metric-latency|metric-success|metric-success-rate|operator guidance|guidance' "$TMP_BUNDLE" | head -n 160 || true
  echo
  grep -En '/events/ops|/events/reflections|EventSource|ops.state|mb:ops:update|reflections|metric-agents|metric-tasks|metric-latency|metric-success|metric-success-rate' "$TMP_CORE" | head -n 160 || true
  echo

  echo "===== QUICK VERDICT ====="

  matilda_shell=0
  matilda_bundle=0
  delegation_shell=0
  delegation_bundle=0
  ops_bundle=0
  reflections_bundle=0
  agent_bundle=0
  metrics_bundle=0

  grep -q 'matilda-chat-root' "$TMP_DASH" && matilda_shell=1 || true
  grep -qi 'matilda-chat-root' "$TMP_BUNDLE" && matilda_bundle=1 || true

  grep -q 'delegation-input' "$TMP_DASH" && grep -q 'delegation-submit' "$TMP_DASH" && delegation_shell=1 || true
  grep -qi '/api/delegate-task' "$TMP_BUNDLE" && delegation_bundle=1 || true

  grep -qi '/events/ops' "$TMP_BUNDLE" && ops_bundle=1 || true
  grep -qi '/events/ops' "$TMP_CORE" && ops_bundle=1 || true

  grep -qi '/events/reflections' "$TMP_BUNDLE" && reflections_bundle=1 || true
  grep -qi '/events/reflections' "$TMP_CORE" && reflections_bundle=1 || true

  grep -qi 'agent-status-container' "$TMP_BUNDLE" && grep -qi 'metric-agents' "$TMP_BUNDLE" && agent_bundle=1 || true

  if grep -qi 'metric-tasks' "$TMP_BUNDLE" || grep -qi 'metric-tasks' "$TMP_CORE"; then
    metrics_bundle=1
  fi

  if [ "$matilda_shell" -eq 1 ] && [ "$matilda_bundle" -eq 1 ]; then
    echo "MATILDA_CHAT=present_in_shell_and_bundle (likely wired)"
  elif [ "$matilda_shell" -eq 1 ]; then
    echo "MATILDA_CHAT=shell_only (likely unwired)"
  else
    echo "MATILDA_CHAT=missing_from_shell"
  fi

  if [ "$delegation_shell" -eq 1 ] && [ "$delegation_bundle" -eq 1 ]; then
    echo "TASK_DELEGATION=present_in_shell_and_bundle (likely wired)"
  elif [ "$delegation_shell" -eq 1 ]; then
    echo "TASK_DELEGATION=shell_only (likely unwired)"
  else
    echo "TASK_DELEGATION=missing_from_shell"
  fi

  if [ "$ops_bundle" -eq 1 ]; then
    echo "OPS_STREAM=reference_present"
  else
    echo "OPS_STREAM=no_reference_detected"
  fi

  if [ "$reflections_bundle" -eq 1 ]; then
    echo "REFLECTIONS_STREAM=reference_present"
  else
    echo "REFLECTIONS_STREAM=no_reference_detected"
  fi

  if [ "$agent_bundle" -eq 1 ]; then
    echo "AGENT_POOL_AND_SIGNAL_ROW=likely wired"
  else
    echo "AGENT_POOL_AND_SIGNAL_ROW=unclear_or_missing"
  fi

  if [ "$metrics_bundle" -eq 1 ]; then
    echo "TELEMETRY_METRICS=reference_present"
  else
    echo "TELEMETRY_METRICS=no_reference_detected"
  fi
  echo

  echo "NEXT SAFE INTERPRETATION"
  echo "- If Matilda chat, delegation, ops, reflections, and agent pool all show bundle references,"
  echo "  then the operator workspace and cognition-facing layer survived."
  echo "- If those are present while observational/task consumers are weaker,"
  echo "  then the remaining problem is localized to observational card reattachment."
  echo "- This scan does not prove backend semantic correctness; it proves shipped dashboard consumer presence."
} > "$OUT"

rm -f "$TMP_DASH" "$TMP_BUNDLE" "$TMP_CORE"

sed -n '1,320p' "$OUT"
