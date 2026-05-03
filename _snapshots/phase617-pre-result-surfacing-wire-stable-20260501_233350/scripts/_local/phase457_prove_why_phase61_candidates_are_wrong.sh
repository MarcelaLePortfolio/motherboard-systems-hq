#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/42_why_phase61_candidates_are_wrong.txt"
mkdir -p docs/recovery_full_audit

CANDIDATES=(
  "cba8b3c0|Consolidate operator column into tabbed workspace"
  "74a241ca|Phase 61: consolidate operator workspace layout"
  "df791714|Phase 61: add observational workspace tab system"
  "d2601c1e|Phase 61: convert telemetry column into tabbed observational workspace"
  "9c68c540|Restore Phase 61 dashboard to last good visual state"
)

MARKERS='operator-tabs|observational-tabs|phase61-workspace-grid|phase62-top-row|operator-workspace-card|observational-workspace-card|output-display|Project Visual Output|Critical Ops Alerts|System Reflections'

{
  echo "PHASE 457 - WHY PHASE 61 CANDIDATES ARE WRONG"
  echo "============================================="
  echo
  echo "PURPOSE"
  echo "Prove whether the tested Phase 61 candidates actually changed the served HTML shell,"
  echo "or only changed adjacent CSS/JS/runtime files."
  echo
} > "$OUT"

for item in "${CANDIDATES[@]}"; do
  IFS='|' read -r SHA LABEL <<< "$item"

  {
    echo "===== $SHA ====="
    echo "LABEL=$LABEL"
    echo

    echo "--- public/index.html hash ---"
    git show "${SHA}:public/index.html" 2>/dev/null | shasum -a 256 || echo "MISSING"
    echo

    echo "--- public/dashboard.html hash ---"
    git show "${SHA}:public/dashboard.html" 2>/dev/null | shasum -a 256 || echo "MISSING"
    echo

    echo "--- public/index.html markers ---"
    git show "${SHA}:public/index.html" 2>/dev/null | grep -Eo "$MARKERS" | sort -u || true
    echo

    echo "--- public/dashboard.html markers ---"
    git show "${SHA}:public/dashboard.html" 2>/dev/null | grep -Eo "$MARKERS" | sort -u || true
    echo

    echo "--- index title + size ---"
    TMP1="$(mktemp)"
    git show "${SHA}:public/index.html" > "$TMP1" 2>/dev/null || true
    [ -s "$TMP1" ] && { wc -c "$TMP1"; grep -o '<title>[^<]*</title>' "$TMP1" | head -n 1 || true; } || echo "MISSING"
    rm -f "$TMP1"
    echo

    echo "--- dashboard title + size ---"
    TMP2="$(mktemp)"
    git show "${SHA}:public/dashboard.html" > "$TMP2" 2>/dev/null || true
    [ -s "$TMP2" ] && { wc -c "$TMP2"; grep -o '<title>[^<]*</title>' "$TMP2" | head -n 1 || true; } || echo "MISSING"
    rm -f "$TMP2"
    echo

    echo "--- files touched in commit ---"
    git show --name-only --oneline "$SHA"
    echo
  } >> "$OUT"
done

{
  echo "===== CROSS-CANDIDATE HTML HASH COMPARISON ====="
  for file in public/index.html public/dashboard.html; do
    echo "--- $file ---"
    for item in "${CANDIDATES[@]}"; do
      IFS='|' read -r SHA LABEL <<< "$item"
      printf '%s  %s  ' "$SHA" "$file"
      git show "${SHA}:${file}" 2>/dev/null | shasum -a 256 || echo "MISSING"
    done
    echo
  done
  echo
  echo "INTERPRETATION"
  echo "If the tested commits keep the same served HTML hash or lack the tab markers,"
  echo "then those commit messages were about surrounding workspace work, not the actual served shell."
  echo "That means the next search must be blob-content driven on public/index.html / public/dashboard.html only."
} >> "$OUT"

sed -n '1,320p' "$OUT"
