
#!/usr/bin/env bash

set -euo pipefail

KEEP_COUNT=5

ROOTS=(

  "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots"

  "/Volumes/Rio Drive/backups"

  "$HOME/Projects/motherboard-systems-hq-clean/backups"

)

echo

echo "========================================"

echo "MOTHERBOARD BACKUP RETENTION REVIEW"

echo "========================================"

echo

for ROOT in "${ROOTS[@]}"; do

  echo

  echo "------------------------------------------------"

  echo "$ROOT"

  echo "------------------------------------------------"

  if [ ! -d "$ROOT" ]; then

    echo "MISSING"

    echo

    continue

  fi

  du -sh "$ROOT" 2>/dev/null || true

  echo

  mapfile -t ITEMS < <(

    find "$ROOT" -mindepth 1 -maxdepth 1 -type d \

      | xargs -I{} stat -f "%m {}" \

      | sort -n

  )

  COUNT=$(find "$ROOT" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

  echo "Directory count: $COUNT"

  echo "Keep newest: $KEEP_COUNT"

  echo

  if [ "$COUNT" -le "$KEEP_COUNT" ]; then

    echo "Nothing eligible for cleanup."

    echo

    continue

  fi

  echo "Candidates older than newest $KEEP_COUNT:"

  echo

  find "$ROOT" -mindepth 1 -maxdepth 1 -type d \

    -exec stat -f "%m %N" {} \; \

    | sort -n \

    | head -n $((COUNT - KEEP_COUNT)) \

    | while read -r MTIME PATHNAME; do

        du -sh "$PATHNAME" 2>/dev/null

      done

  echo

done

echo

echo "NO FILES WERE DELETED."

echo "Review output before performing cleanup."

