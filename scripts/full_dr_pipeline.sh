
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

DRIVE_NAME="Rio Drive"

EXTERNAL="/Volumes/$DRIVE_NAME"

BACKUP_ROOT="$EXTERNAL/backups"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "RUNNING SAFE DR SYSTEM"

if [ ! -d "$EXTERNAL" ]; then

  echo "❌ EXTERNAL DRIVE NOT MOUNTED"

  exit 1

fi

mkdir -p "$BACKUP_ROOT"

USAGE=$(df -H "$EXTERNAL" | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$USAGE" -ge 85 ]; then

  echo "❌ EXTERNAL DRIVE TOO FULL"

  exit 1

fi

WORKDIR="$BACKUP_ROOT/.staging_$TIMESTAMP"

rm -rf "$WORKDIR"

mkdir -p "$WORKDIR/files"

git bundle create "$WORKDIR/repo.bundle" --all

# FIXED RSYNC (NO LINE CONTINUATIONS — mac-safe)

rsync -a --exclude="backups" --exclude=".git" "$ROOT_DIR/" "$WORKDIR/files/"

FINAL_TMP="$BACKUP_ROOT/source_$TIMESTAMP.tar.gz.tmp"

tar -czf "$FINAL_TMP" -C "$WORKDIR" .

mv "$FINAL_TMP" "$BACKUP_ROOT/source_$TIMESTAMP.tar.gz"

rm -rf "$WORKDIR"

cd "$BACKUP_ROOT"

ls -1t source_*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm -f

ls -1t repo_*.bundle 2>/dev/null | tail -n +11 | xargs -r rm -f

echo "✔ DR COMPLETE: $TIMESTAMP"

