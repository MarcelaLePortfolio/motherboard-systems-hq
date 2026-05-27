
#!/bin/bash

set -e

echo "🛡️ Guard Layer: Pre-flight Safety Check"

EXTERNAL=$(ls /Volumes | grep -v "Macintosh HD" | head -n 1)

DEST="/Volumes/$EXTERNAL/Motherboard_External_Backup"

PROJECT_SIZE_MB=$(du -sm . 2>/dev/null | awk '{print $1}')

echo "📦 Project size: ${PROJECT_SIZE_MB}MB"

# -----------------------------

# THRESHOLDS

# -----------------------------

WARN_MB=60000   # ~60GB

BLOCK_MB=80000  # ~80GB

# -----------------------------

# EXTERNAL DRIVE CHECK

# -----------------------------

if [ -z "$EXTERNAL" ] || [ ! -d "$DEST" ]; then

  echo "❌ External backup drive not available"

  exit 1

fi

echo "📍 External OK: $DEST"

# -----------------------------

# SAFETY LOGIC

# -----------------------------

if [ "$PROJECT_SIZE_MB" -ge "$BLOCK_MB" ]; then

  echo "🚨 BLOCKED: Project exceeds safe limit (${BLOCK_MB}MB)"

  echo "👉 Run backup before continuing work"

  exit 1

fi

if [ "$PROJECT_SIZE_MB" -ge "$WARN_MB" ]; then

  echo "⚠️ WARNING: Project above safe threshold (${WARN_MB}MB)"

  echo "👉 Recommended: run backup system now"

fi

echo "✅ Guard check passed"

