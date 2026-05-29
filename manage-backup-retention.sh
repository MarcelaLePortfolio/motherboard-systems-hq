
#!/usr/bin/env bash

set -euo pipefail

KEEP_COUNT=5

review_root() {

  ROOT="$1"

  echo

  echo "------------------------------------------------"

  echo "$ROOT"

  echo "------------------------------------------------"

  if [ ! -d "$ROOT" ]; then

    echo "MISSING"

    return

  fi

  du -sh "$ROOT" 2>/dev/null || true

  COUNT="$(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | wc -l | tr -d ' ')"

  echo "Directory count: $COUNT"

  echo "Keep newest: $KEEP_COUNT"

  echo

  if [ "$COUNT" -le "$KEEP_COUNT" ]; then

    echo "Nothing eligible for cleanup."

    return

  fi

  echo "Candidates older than newest $KEEP_COUNT:"

  echo

  CANDIDATE_FILE="$(mktemp)"

  find "$ROOT" -mindepth 1 -maxdepth 1 -type d -exec stat -f "%m %N" {} \; 2>/dev/null > "$CANDIDATE_FILE"

  sort -n "$CANDIDATE_FILE" | head -n "$((COUNT - KEEP_COUNT))" > "$CANDIDATE_FILE.sorted"

  while IFS= read -r line; do

    PATHNAME="$(printf '%s\n' "$line" | cut -d' ' -f2-)"

    du -sh "$PATHNAME" 2>/dev/null || true

  done < "$CANDIDATE_FILE.sorted"

  rm -f "$CANDIDATE_FILE" "$CANDIDATE_FILE.sorted"

}

echo

echo "========================================"

echo "MOTHERBOARD BACKUP RETENTION REVIEW"

echo "========================================"

review_root "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots"

review_root "/Volumes/Rio Drive/backups"

review_root "$HOME/Projects/motherboard-systems-hq-clean/backups"

echo

echo "NO FILES WERE DELETED."

echo "Review output before performing cleanup."

