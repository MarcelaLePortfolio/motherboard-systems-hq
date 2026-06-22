
#!/usr/bin/env bash

set -euo pipefail

REPORT="RIO_DRIVE_DISASTER_BACKUP_INSPECTION_V2.txt"

RIO="/Volumes/Rio Drive"

PREVIEW="_dashboard_candidate_previews/rio-drive-latest"

{

  echo "===== RIO DRIVE DISASTER BACKUP INSPECTION V2 ====="

  date

  echo

  echo "===== VERIFY RIO DRIVE EXISTS ====="

  if [ ! -d "$RIO" ]; then

    echo "ERROR: Rio Drive is not mounted at: $RIO"

    echo "Mount Rio Drive, then rerun this script."

    exit 1

  fi

  echo "Rio Drive found: $RIO"

  echo

  echo "===== BACKUP ROOTS ====="

  find "$RIO" -maxdepth 5 -type d \( -iname 'backups' -o -iname 'snapshots' -o -iname 'Motherboard_Storage' \) 2>/dev/null | sort

  echo

  echo "===== NEWEST ARCHIVES ====="

  find "$RIO" -type f \( -iname 'source_*.tar.gz' -o -iname 'repo_*.bundle' \) 2>/dev/null -print0 \

    | xargs -0 stat -f "%m %N" 2>/dev/null \

    | sort -nr \

    | head -80

  echo

  echo "===== NEWEST DASHBOARD FILES ====="

  find "$RIO" -type f \( -iname 'index.html' -o -iname 'dashboard.html' -o -iname 'bundle.js' \) 2>/dev/null -print0 \

    | xargs -0 stat -f "%m %N" 2>/dev/null \

    | sort -nr \

    | head -120

  echo

  echo "===== PREVIEW LATEST DIRECT DASHBOARD FILES ====="

  mkdir -p "$PREVIEW"

  LATEST_INDEX="$(find "$RIO" -type f -iname 'index.html' 2>/dev/null -print0 | xargs -0 stat -f "%m %N" 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || true)"

  LATEST_DASH="$(find "$RIO" -type f -iname 'dashboard.html' 2>/dev/null -print0 | xargs -0 stat -f "%m %N" 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || true)"

  LATEST_BUNDLE="$(find "$RIO" -type f -iname 'bundle.js' 2>/dev/null -print0 | xargs -0 stat -f "%m %N" 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || true)"

  if [ -n "$LATEST_INDEX" ]; then

    cp "$LATEST_INDEX" "$PREVIEW/index.html"

    echo "Copied index: $LATEST_INDEX"

  fi

  if [ -n "$LATEST_DASH" ]; then

    cp "$LATEST_DASH" "$PREVIEW/dashboard.html"

    echo "Copied dashboard: $LATEST_DASH"

  fi

  if [ -n "$LATEST_BUNDLE" ]; then

    cp "$LATEST_BUNDLE" "$PREVIEW/bundle.js"

    echo "Copied bundle: $LATEST_BUNDLE"

  fi

  echo

  echo "Open preview:"

  echo "http://localhost:8099/_dashboard_candidate_previews/rio-drive-latest/index.html"

  echo

  echo "Do not restore yet. First confirm this preview visually matches the latest dashboard."

} | tee "$REPORT"

git add inspect-rio-drive-disaster-backups-v2.sh "$REPORT" "$PREVIEW" || true

git commit -m "Inspect Rio Drive disaster backup dashboard candidate" || true

git push

