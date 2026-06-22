
#!/usr/bin/env bash

set -euo pipefail

REPORT="LATEST_SNAPSHOT_DASHBOARD_CANDIDATE_INSPECTION.txt"

WORKDIR="/tmp/latest-dashboard-snapshot-inspect"

rm -rf "$WORKDIR"

mkdir -p "$WORKDIR"

{

  echo "===== LATEST SNAPSHOT DASHBOARD CANDIDATE INSPECTION ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -8

  echo

  echo "===== FIND LATEST SNAPSHOT ARCHIVES ====="

  find backups external_backups snapshots recovery-vault -type f \( -iname '*.tar.gz' -o -iname '*.bundle' \) 2>/dev/null \

    -exec stat -f "%m %N" {} \; | sort -nr | head -40

  echo

  LATEST_SOURCE="$(find backups external_backups snapshots recovery-vault -type f -iname 'source_*.tar.gz' 2>/dev/null \

    -exec stat -f "%m %N" {} \; | sort -nr | head -1 | cut -d' ' -f2-)"

  echo "===== LATEST SOURCE SNAPSHOT ====="

  echo "${LATEST_SOURCE:-NONE}"

  echo

  if [ -z "${LATEST_SOURCE:-}" ]; then

    echo "No source_*.tar.gz snapshot found. Stop here."

    exit 0

  fi

  echo "===== EXTRACT LATEST SOURCE SNAPSHOT READ-ONLY ====="

  tar -xzf "$LATEST_SOURCE" -C "$WORKDIR"

  echo "Extracted to $WORKDIR"

  echo

  echo "===== DASHBOARD FILES IN SNAPSHOT ====="

  find "$WORKDIR" -type f \( -path '*/public/index.html' -o -path '*/public/dashboard.html' -o -path '*/public/bundle.js' \) -exec wc -c {} \; | sort

  echo

  SNAP_INDEX="$(find "$WORKDIR" -type f -path '*/public/index.html' | head -1 || true)"

  SNAP_DASH="$(find "$WORKDIR" -type f -path '*/public/dashboard.html' | head -1 || true)"

  SNAP_BUNDLE="$(find "$WORKDIR" -type f -path '*/public/bundle.js' | head -1 || true)"

  echo "===== SNAPSHOT INDEX MARKERS ====="

  if [ -n "$SNAP_INDEX" ]; then

    grep -ni "recent tasks\|task history\|execution inspector\|artifact preview\|matilda\|operator guidance\|phase715\|phase719\|phase724\|phase725\|phase530\|preview" "$SNAP_INDEX" | head -160 || true

  else

    echo "No public/index.html found in snapshot."

  fi

  echo

  echo "===== SNAPSHOT DASHBOARD MARKERS ====="

  if [ -n "$SNAP_DASH" ]; then

    grep -ni "recent tasks\|task history\|execution inspector\|artifact preview\|matilda\|operator guidance\|phase715\|phase719\|phase724\|phase725\|phase530\|preview" "$SNAP_DASH" | head -160 || true

  else

    echo "No public/dashboard.html found in snapshot."

  fi

  echo

  echo "===== CURRENT VS SNAPSHOT SIZE COMPARISON ====="

  wc -c public/index.html public/dashboard.html public/bundle.js || true

  [ -n "$SNAP_INDEX" ] && wc -c "$SNAP_INDEX"

  [ -n "$SNAP_DASH" ] && wc -c "$SNAP_DASH"

  [ -n "$SNAP_BUNDLE" ] && wc -c "$SNAP_BUNDLE"

  echo

  echo "===== DIFFERENCE CHECK ====="

  if [ -n "$SNAP_INDEX" ]; then

    diff -q public/index.html "$SNAP_INDEX" && echo "Current index matches latest snapshot index." || echo "Current index differs from latest snapshot index."

  fi

  if [ -n "$SNAP_DASH" ]; then

    diff -q public/dashboard.html "$SNAP_DASH" && echo "Current dashboard matches latest snapshot dashboard." || echo "Current dashboard differs from latest snapshot dashboard."

  fi

  if [ -n "$SNAP_BUNDLE" ]; then

    diff -q public/bundle.js "$SNAP_BUNDLE" && echo "Current bundle matches latest snapshot bundle." || echo "Current bundle differs from latest snapshot bundle."

  fi

  echo

  echo "===== PREVIEW COPY ====="

  mkdir -p _dashboard_candidate_previews/latest-snapshot

  if [ -n "$SNAP_INDEX" ]; then

    cp "$SNAP_INDEX" _dashboard_candidate_previews/latest-snapshot/index.html

    echo "_dashboard_candidate_previews/latest-snapshot/index.html"

  fi

  if [ -n "$SNAP_DASH" ]; then

    cp "$SNAP_DASH" _dashboard_candidate_previews/latest-snapshot/dashboard.html

    echo "_dashboard_candidate_previews/latest-snapshot/dashboard.html"

  fi

  echo

  echo "===== SAFE NEXT ACTION ====="

  echo "Open the latest snapshot preview before restoring it:"

  echo "http://localhost:8099/_dashboard_candidate_previews/latest-snapshot/index.html"

  echo

  echo "Do not restore from snapshot until this preview is visually confirmed as the intended latest dashboard."

} | tee "$REPORT"

git add inspect-latest-snapshot-dashboard-candidate.sh "$REPORT" _dashboard_candidate_previews/latest-snapshot || true

git commit -m "Inspect latest snapshot dashboard candidate" || true

git push

