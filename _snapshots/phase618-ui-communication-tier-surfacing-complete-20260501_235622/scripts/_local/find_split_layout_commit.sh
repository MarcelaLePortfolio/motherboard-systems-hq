#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/SPLIT_LAYOUT_COMMIT_DISCOVERY.txt"
TARGET="$ROOT/public/dashboard.html"

{
  echo "SPLIT LAYOUT COMMIT DISCOVERY"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo "Target: $TARGET"
  echo

  if [[ ! -f "$TARGET" ]]; then
    echo "TARGET MISSING: $TARGET"
    exit 1
  fi

  echo "=== CURRENT FILE HISTORY ==="
  git log --oneline -- "$TARGET" | head -n 60
  echo

  echo "=== COMMITS TOUCHING LIKELY LAYOUT STRINGS ==="
  git log -S'agentStatusContainer' --oneline -- "$TARGET" || true
  git log -S'recentTasks' --oneline -- "$TARGET" || true
  git log -S'delegateButton' --oneline -- "$TARGET" || true
  git log -S'taskActivityCanvas' --oneline -- "$TARGET" || true
  echo

  echo "=== PATCH SNIPPETS FOR LAST 12 COMMITS ON TARGET ==="
  for commit in $(git log --format='%H' -- "$TARGET" | head -n 12); do
    echo "----------------------------------------------------------------"
    echo "COMMIT: $commit"
    git show --stat --oneline --no-patch "$commit"
    echo
    git show "$commit:$TARGET" 2>/dev/null | grep -nE 'grid|flex|Agent Pool|Recent Tasks|Matilda|Delegat|Telemetry|Subsystem|taskActivityCanvas|agentStatusContainer|recentTasks|delegateButton|tab|workspace|metrics' | head -n 120 || true
    echo
  done

  echo "=== RESTORE COMMAND TEMPLATE ==="
  echo 'GOOD_COMMIT=REPLACE_ME'
  echo 'git checkout "$GOOD_COMMIT" -- public/dashboard.html'
  echo 'git diff -- public/dashboard.html'
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
