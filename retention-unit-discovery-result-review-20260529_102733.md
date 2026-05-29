# Retention Unit Discovery Result Review

Latest discovery report: retention-unit-discovery-20260529_102414.md

## Latest Discovery Contents

# Retention Unit Discovery Verification

This is read-only. It identifies backup units without deleting, archiving, or compressing anything.

## /Volumes/Rio Drive/backups

exists: YES
318M	/Volumes/Rio Drive/backups

### Top-level files

### Top-level directories containing backup files
317M | nested_backup_files=1 | /Volumes/Rio Drive/backups/.staging_20260527_160657

### Counts
top_level_files=0
top_level_dirs_with_backup_files=1

## /Volumes/Rio Drive/Motherboard_External_Backup/snapshots

exists: YES
6.9G	/Volumes/Rio Drive/Motherboard_External_Backup/snapshots

### Top-level files

### Top-level directories containing backup files
526M | nested_backup_files=1 | /Volumes/Rio Drive/Motherboard_External_Backup/snapshots/20260527_135824_snapshot
526M | nested_backup_files=1 | /Volumes/Rio Drive/Motherboard_External_Backup/snapshots/20260527_140933_snapshot

## Current Manager Script Safety Markers

22:KEEP_NEWEST_PER_ROOT=5
24:MIN_AGE_SECONDS=86400
96:  find "$BASE" -maxdepth 1 -type f \( -name "*.tar.gz" -o -name "*.bundle" \) -print 2>/dev/null | while read -r f; do
110:  if [ "$COUNT" -le "$KEEP_NEWEST_PER_ROOT" ] && [ "${ROOT_BYTES:-0}" -le "$MAX_BYTES" ]; then
116:  DELETE_LIMIT=$((COUNT - KEEP_NEWEST_PER_ROOT))
134:    if [ "$INDEX" -lt "$DELETE_LIMIT" ] && [ "$age" -ge "$MIN_AGE_SECONDS" ]; then
140:    if [ "${ROOT_BYTES:-0}" -gt "$MAX_BYTES" ] && [ "$age" -ge "$MIN_AGE_SECONDS" ]; then
154:          rm -f "$path"
218:  "keep_newest_per_root": $KEEP_NEWEST_PER_ROOT,
220:  "minimum_age_seconds_before_delete": $MIN_AGE_SECONDS,
