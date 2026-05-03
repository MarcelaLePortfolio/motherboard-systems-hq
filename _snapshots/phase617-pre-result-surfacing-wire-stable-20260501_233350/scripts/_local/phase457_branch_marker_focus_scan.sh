#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)" || exit 1
mkdir -p docs/recovery_full_audit

OUTPUT="docs/recovery_full_audit/11_branch_marker_focus_scan.txt"

{
  echo "PHASE 457 - BRANCH MARKER FOCUS SCAN"
  echo "------------------------------------"
  echo
  echo "PURPOSE"
  echo "Identify which candidate branches actually contain the newer dashboard/layout marker strings."
  echo
  echo "CANDIDATE_BRANCHES"
  printf "%s\n" \
    "docs/phase57b-dashboard-polish" \
    "feature/phase58a-event-stream-containment" \
    "feature/phase58b-probe-lifecycle-visibility" \
    "feature/phase59-console-composition-pass" \
    "fix/dashboard-layout-restore-9579482a" \
    "feature/matilda-chat-ui" \
    "feature/phase13-operator-polish" \
    "feature/phase15-ops-polish" \
    "feature/phase41-dashboard-alive-smoke-pr" \
    "feature/post-golden-next"
  echo
} > "$OUTPUT"

for b in \
  docs/phase57b-dashboard-polish \
  feature/phase58a-event-stream-containment \
  feature/phase58b-probe-lifecycle-visibility \
  feature/phase59-console-composition-pass \
  fix/dashboard-layout-restore-9579482a \
  feature/matilda-chat-ui \
  feature/phase13-operator-polish \
  feature/phase15-ops-polish \
  feature/phase41-dashboard-alive-smoke-pr \
  feature/post-golden-next
do
  {
    echo
    echo "===== BRANCH: $b ====="
    if ! git rev-parse --verify "$b" >/dev/null 2>&1; then
      echo "STATUS=MISSING_BRANCH"
      continue
    fi

    echo "TIP_COMMIT=$(git rev-parse --short "$b")"
    echo "[recent]"
    git log --oneline -n 8 "$b" || true
    echo

    echo "[marker hits]"
    git grep -n -E \
      'Operator Console|Matilda Chat Console|Task Delegation|Probe lifecycle|probe lifecycle|Idle state|idle state|Heartbeat activity|Project Visual|Recent Tasks|Agent Pool|Atlas Subsystem Status|Task Activity Over Time' \
      "$b" -- . 2>/dev/null | head -n 80 || true
  } >> "$OUTPUT"
done

echo "WROTE=$OUTPUT"
