#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/43_blob_driven_dashboard_shell_shortlist.txt"

{
  echo "PHASE 457 - BLOB-DRIVEN DASHBOARD SHELL SHORTLIST"
  echo "================================================="
  echo
  echo "PURPOSE"
  echo "Build a shortlist using actual public/dashboard.html blob content and visible markers only."
  echo
  echo "REMEMBERED TARGET MARKERS"
  echo "- operator-tabs present"
  echo "- observational-tabs present"
  echo "- phase62-top-row present"
  echo "- no Project Visual Output"
  echo "- no Critical Ops Alerts"
  echo "- no System Reflections"
  echo "- no output-display"
  echo
  echo "STRICT MATCH CANDIDATES"
  echo "sha | dashboard_hash | bytes | markers | subject"
} > "$OUT"

git log --all --format='%H%x09%s' -- public/dashboard.html | \
while IFS=$'\t' read -r SHA SUBJECT; do
  DASH_FILE="$(mktemp)"
  if ! git show "${SHA}:public/dashboard.html" > "$DASH_FILE" 2>/dev/null; then
    rm -f "$DASH_FILE"
    continue
  fi

  HASH="$(shasum -a 256 "$DASH_FILE" | awk '{print $1}')"
  BYTES="$(wc -c < "$DASH_FILE" | tr -d ' ')"
  MARKERS="$(grep -Eo 'operator-tabs|observational-tabs|phase61-workspace-grid|phase62-top-row|operator-workspace-card|observational-workspace-card|Project Visual Output|Critical Ops Alerts|System Reflections|output-display|Agent Pool|Atlas Subsystem Status|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Task Events|Task History' "$DASH_FILE" | sort -u | paste -sd, - || true)"

  if grep -q 'operator-tabs' "$DASH_FILE" \
    && grep -q 'observational-tabs' "$DASH_FILE" \
    && grep -q 'phase62-top-row' "$DASH_FILE" \
    && ! grep -q 'Project Visual Output' "$DASH_FILE" \
    && ! grep -q 'Critical Ops Alerts' "$DASH_FILE" \
    && ! grep -q 'System Reflections' "$DASH_FILE" \
    && ! grep -q 'output-display' "$DASH_FILE"
  then
    printf '%s | %s | bytes=%s | markers=%s | %s\n' "$SHA" "$HASH" "$BYTES" "${MARKERS:-none}" "$SUBJECT" >> "$OUT"
  fi

  rm -f "$DASH_FILE"
done

{
  echo
  echo "NEAR-MISS CANDIDATES"
  echo "sha | dashboard_hash | bytes | markers | subject"
} >> "$OUT"

git log --all --format='%H%x09%s' -- public/dashboard.html | \
while IFS=$'\t' read -r SHA SUBJECT; do
  DASH_FILE="$(mktemp)"
  if ! git show "${SHA}:public/dashboard.html" > "$DASH_FILE" 2>/dev/null; then
    rm -f "$DASH_FILE"
    continue
  fi

  HASH="$(shasum -a 256 "$DASH_FILE" | awk '{print $1}')"
  BYTES="$(wc -c < "$DASH_FILE" | tr -d ' ')"
  MARKERS="$(grep -Eo 'operator-tabs|observational-tabs|phase61-workspace-grid|phase62-top-row|operator-workspace-card|observational-workspace-card|Project Visual Output|Critical Ops Alerts|System Reflections|output-display|Agent Pool|Atlas Subsystem Status|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Task Events|Task History' "$DASH_FILE" | sort -u | paste -sd, - || true)"

  if grep -q 'operator-tabs' "$DASH_FILE" && grep -q 'observational-tabs' "$DASH_FILE"; then
    printf '%s | %s | bytes=%s | markers=%s | %s\n' "$SHA" "$HASH" "$BYTES" "${MARKERS:-none}" "$SUBJECT"
  fi

  rm -f "$DASH_FILE"
done | awk '!seen[$2]++' | head -n 25 >> "$OUT"

{
  echo
  echo "NEXT"
  echo "Boot only strict-match candidates first."
  echo "If strict-match is empty, boot the first near-miss entries that still include phase62-top-row."
} >> "$OUT"

sed -n '1,260p' "$OUT"
