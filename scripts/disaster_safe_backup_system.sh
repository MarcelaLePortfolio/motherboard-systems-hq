
#!/bin/bash

set -e

echo "🧠 Disaster-Safe Backup System Starting..."

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

echo "📍 Git branch: $BRANCH"

# -----------------------------

# DISK SAFETY CHECKS

# -----------------------------

echo "📊 Checking disk usage..."

PROJECT_SIZE=$(du -sm . 2>/dev/null | awk '{print $1}')

echo "📦 Project size (MB): $PROJECT_SIZE"

if [ "$PROJECT_SIZE" -gt 80000 ]; then

  echo "🚨 CRITICAL: Project > 80GB equivalent"

  echo "⛔ Backup recommended before continuing heavy work"

elif [ "$PROJECT_SIZE" -gt 60000 ]; then

  echo "⚠️ WARNING: Project > 60GB"

else

  echo "✅ Disk usage within safe range"

fi

# -----------------------------

# EXTERNAL DRIVE DETECTION

# -----------------------------

EXTERNAL=$(ls /Volumes | grep -v "Macintosh HD" | head -n 1)

if [ -z "$EXTERNAL" ]; then

  echo "❌ No external drive detected"

  exit 1

fi

DEST="/Volumes/$EXTERNAL/Motherboard_External_Backup"

echo "📦 External target: $DEST"

mkdir -p "$DEST"/{snapshots,logs,archives,system_backups,db_dumps}

# -----------------------------

# SNAPSHOTS (COPY SAFE MODE)

# -----------------------------

if [ -d "snapshots" ]; then

  echo "📸 Copying snapshots (safe mode)..."

  rsync -av snapshots/ "$DEST/snapshots/$(date +%Y%m%d_%H%M%S)_snapshots/"

fi

# -----------------------------

# LOGS (COPY SAFE MODE)

# -----------------------------

echo "📄 Copying logs..."

find . -type f \( \

  -name "*.log" -o \

  -name "*postgres_snapshot.sql" -o \

  -name "*docker*.txt" -o \

  -name "*task-events*.txt" \

\) -exec rsync -av {} "$DEST/logs/" \; 2>/dev/null || true

# -----------------------------

# ARCHIVES

# -----------------------------

if [ -d "ts-backup" ]; then

  echo "📦 Archiving ts-backup..."

  rsync -av ts-backup/ "$DEST/archives/ts-backup/"

fi

if [ -d "RioDrive" ]; then

  echo "📦 Archiving RioDrive..."

  rsync -av RioDrive/ "$DEST/archives/RioDrive/"

fi

# -----------------------------

# SYSTEM ZIP BACKUPS

# -----------------------------

echo "📦 Copying zip backups..."

rsync -av *.zip "$DEST/system_backups/" 2>/dev/null || true

# -----------------------------

# SUMMARY

# -----------------------------

echo "🧹 Cleanup check (no deletion in safe mode)"

echo "📍 Backup destination: $DEST"

echo "✅ Disaster-safe backup complete"

