#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)" || exit 1

mkdir -p docs/recovery_full_audit

ROOT_BRANCH="phase119-dashboard-cognition-contract"
RECOVERY_BRANCH="feature/phase59-dashboard-composition"

{
  echo "=== DIFF OF KEY UI / WIRING FILES BETWEEN ROOT AND RECOVERY ==="
  for f in \
    public/js/phase58c_idle_states.js \
    public/js/phase58d_operator_console.js \
    public/js/probe-lifecycle-card.js \
    server.mjs \
    server/routes/api-tasks-postgres.mjs \
    server/routes/task-events-sse.mjs \
    server/tasks-mutations.mjs \
    src/demo/promptToDemoRequest.ts
  do
    echo
    echo "===== $f ====="
    git diff --stat "$ROOT_BRANCH..$RECOVERY_BRANCH" -- "$f" || true
  done
} > docs/recovery_full_audit/07_key_file_diffs.txt

{
  echo "=== OTHER HIGH-PROBABILITY BRANCH CANDIDATES ==="
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
    echo
    echo "----- BRANCH $b -----"
    git rev-parse --verify "$b" >/dev/null 2>&1 || { echo "MISSING_BRANCH"; continue; }
    echo "[tip]"
    git log --oneline -n 12 "$b" || true
    echo
    echo "[ui marker hits unique to branch tip tree]"
    git grep -n -E 'Operator Console|Matilda Chat Console|Task Delegation|Probe lifecycle|Idle|Heartbeat activity|Project Visual|Recent Tasks|Agent Pool|Atlas Subsystem Status' "$b" -- . 2>/dev/null | head -n 40 || true
  done
} > docs/recovery_full_audit/08_other_candidate_branches.txt

{
  echo "=== SNAPSHOTS / ARCHIVES / BACKUPS ==="
  find . ../mbhq_recovery_worktrees .. -maxdepth 4 \( \
    -iname '*snapshot*' -o \
    -iname '*.tar.gz' -o \
    -iname '*.tgz' -o \
    -iname '*.bak' -o \
    -iname '*backup*' -o \
    -iname '*restore*' \
  \) 2>/dev/null | sort -u | head -n 400
} > docs/recovery_full_audit/09_snapshot_archive_inventory.txt

cat > docs/recovery_full_audit/10_next_review_index.txt <<'INDEXEOF'
=== SUMMARY CANDIDATES ===
Review these files next:
docs/recovery_full_audit/03_branch_contains_matrix.txt
docs/recovery_full_audit/05_ui_marker_search.txt
docs/recovery_full_audit/06_key_file_histories.txt
docs/recovery_full_audit/08_other_candidate_branches.txt
docs/recovery_full_audit/09_snapshot_archive_inventory.txt
INDEXEOF
