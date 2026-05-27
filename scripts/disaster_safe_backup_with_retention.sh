
#!/bin/bash

set -e

echo "🧠 Backup System (Retention Mode) Starting..."

EXTERNAL=$(ls /Volumes | grep -v "Macintosh HD" | head -n 1)

if [ -z "$EXTERNAL" ]; then

  echo "❌ No external drive detected"

  exit 1

fi

DEST="/Volumes/$EXTERNAL/Motherboard_External_Backup"

mkdir -p "$DEST"/{snapshots,logs,archives,system_backups}

# -----------------------------

# CONFIGURATION

# -----------------------------

RETENTION_SNAPSHOTS=7

RETENTION_LOGS_DAYS=14

echo "📦 Destination: $DEST"

echo "🧾 Snapshot retention: last $RETENTION_SNAPSHOTS runs"

echo "📄 Log retention: $RETENTION_LOGS_DAYS days"

# -----------------------------

# CREATE SNAPSHOT

# -----------------------------

SNAPSHOT_DIR="$DEST/snapshots/$(date +%Y%m%d_%H%M%S)_snapshot"

mkdir -p "$SNAPSHOT_DIR"

if [ -d "snapshots" ]; then

  echo "📸 Copying snapshots..."

  rsync -av snapshots/ "$SNAPSHOT_DIR/"

fi

# -----------------------------

# COPY LOGS

# -----------------------------

echo "📄 Copying logs..."

find . -type f \( \

  -name "*.log" -o \

  -name "*postgres_snapshot.sql" -o \

  -name "*docker*.txt" -o \

  -name "*task-events*.txt" \

\) -exec rsync -av {} "$DEST/logs/" \; 2>/dev/null || true

# -----------------------------

# ARCHIVES (SAFE COPY)

# -----------------------------

[ -d "ts-backup" ] && rsync -av ts-backup/ "$DEST/archives/ts-backup/" || true

[ -d "RioDrive" ] && rsync -av RioDrive/ "$DEST/archives/RioDrive/" || true

# -----------------------------

# ZIP BACKUPS

# -----------------------------

rsync -av *.zip "$DEST/system_backups/" 2>/dev/null || true

# -----------------------------

# RETENTION POLICY (SNAPSHOTS)

# -----------------------------

echo "🧹 Applying snapshot retention policy..."

cd "$DEST/snapshots"

ls -1dt *_snapshot 2>/dev/null | tail -n +$((RETENTION_SNAPSHOTS+1)) | while read old; do

  echo "🗑 Removing old snapshot: $old"

  rm -rf "$old"

done

# -----------------------------

# RETENTION POLICY (LOGS)

# -----------------------------

echo "🧹 Cleaning old logs (> $RETENTION_LOGS_DAYS days)..."

find "$DEST/logs" -type f -mtime +$RETENTION_LOGS_DAYS -exec rm -f {} \; 2>/dev/null || true

# -----------------------------

# SUMMARY

# -----------------------------

echo "✅ Backup complete with retention policy applied"

echo "📍 Destination: $DEST"

