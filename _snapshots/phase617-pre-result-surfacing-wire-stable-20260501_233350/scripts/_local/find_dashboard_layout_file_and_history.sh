#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/DASHBOARD_LAYOUT_FILE_DISCOVERY.txt"

SEARCH_DIRS=()
for d in app src components pages; do
  if [[ -d "$ROOT/$d" ]]; then
    SEARCH_DIRS+=("$ROOT/$d")
  fi
done

{
  echo "DASHBOARD LAYOUT FILE DISCOVERY"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== CANDIDATE FILES BY UI LABEL SEARCH ==="
  if [[ ${#SEARCH_DIRS[@]} -gt 0 ]]; then
    grep -RIlE 'Matilda Chat Console|Task Delegation|Operator Console|Agent Pool|Recent Tasks|Task Activity Over Time|Atlas Subsystem Status|OPERATOR TOOLS|ACTIVITY PANELS|SUBSYSTEM STATUS' \
      "${SEARCH_DIRS[@]}" \
      --include='*.tsx' --include='*.ts' --include='*.jsx' --include='*.js' \
      2>/dev/null | sort | tee /tmp/dashboard_candidates.txt
  else
    echo "No app/src/components/pages directories found"
    : > /tmp/dashboard_candidates.txt
  fi
  echo

  TOP_FILE="$(head -n 1 /tmp/dashboard_candidates.txt || true)"
  echo "TOP_FILE=$TOP_FILE"
  echo

  if [[ -n "${TOP_FILE:-}" && -f "$TOP_FILE" ]]; then
    echo "=== TOP FILE: FIRST 260 LINES ==="
    sed -n '1,260p' "$TOP_FILE"
    echo
    echo "=== TOP FILE: GIT HISTORY ==="
    git log --oneline -- "$TOP_FILE" | head -n 50
    echo
    echo "=== TOP FILE: PATCH HISTORY (FIRST 400 LINES) ==="
    git log -p -- "$TOP_FILE" | sed -n '1,400p'
  fi

  echo
  echo "=== ALL MATCHING FILES WITH GIT HISTORY HEADLINES ==="
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    echo "--- $f ---"
    git log --oneline -- "$f" | head -n 15
    echo
  done < /tmp/dashboard_candidates.txt
} | tee "$OUT"

rm -f /tmp/dashboard_candidates.txt
