#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase486_step7_refined_ui_surface_shortlist.txt"
TMP_FILES="$(mktemp)"
TMP_HITS="$(mktemp)"
trap 'rm -f "$TMP_FILES" "$TMP_HITS"' EXIT

find app src components \
  -path '*/node_modules/*' -prune -o \
  -path '*/.next/*' -prune -o \
  -path '*/dist/*' -prune -o \
  -path '*/build/*' -prune -o \
  -type f \( -name '*.tsx' -o -name '*.ts' -o -name '*.jsx' -o -name '*.js' \) -print 2>/dev/null | sort > "$TMP_FILES" || true

if [ -s "$TMP_FILES" ]; then
  xargs grep -nHE 'governance|trace|approval|execution|reporting|intake|ruleId|evaluationResult|MATCH|NO_MATCH|operator|dashboard|console|workspace|panel' < "$TMP_FILES" | sort > "$TMP_HITS" || true
else
  : > "$TMP_HITS"
fi

{
  echo "PHASE 486 — STEP 7"
  echo "REFINED UI SURFACE SHORTLIST"
  echo
  echo "OBJECTIVE"
  echo
  echo "Produce a clean shortlist of real UI implementation surfaces for governance trace panel placement."
  echo "This pass excludes .git, docs, scripts, generated output, and non-UI noise."
  echo
  echo "SEARCH ROOT"
  pwd
  echo
  echo "SEARCH SCOPE"
  echo "app/"
  echo "src/"
  echo "components/"
  echo
  echo "METHOD"
  echo "1. Enumerate UI source files only"
  echo "2. Search for governance / trace / approval / operator / dashboard signals"
  echo "3. Distill likely render hosts"
  echo
  echo "UI SOURCE FILE COUNT"
  wc -l < "$TMP_FILES" | tr -d ' '
  echo
  echo "CANDIDATE FILES WITH MATCH SIGNALS"
  cut -d: -f1 "$TMP_HITS" | sort -u || true
  echo
  echo "HIGH-SIGNAL MATCH LINES"
  sed -n '1,240p' "$TMP_HITS"
  echo
  echo "DISTILLED SHORTLIST"
  cut -d: -f1 "$TMP_HITS" | sort -u | \
    grep -Ei '(dashboard|operator|console|workspace|panel|governance|trace|approval|report|intake|execution)' || true
  echo
  echo "SELECTION RULE"
  echo "Choose the nearest existing dashboard/operator render surface from the distilled shortlist."
  echo "Do not choose contracts, backend logic files, or transport layers."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
