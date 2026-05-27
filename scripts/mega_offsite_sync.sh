
#!/usr/bin/env bash

set -euo pipefail

# =========================

# MEGA OFFSITE SYNC LAYER

# Free-tier safe: throttled + size-aware + opt-in only

# =========================

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_DIR="$ROOT_DIR/backups"

MEGA_REMOTE="MEGA:/motherboard-systems-hq"

echo "MEGA OFFSITE SYNC START"

# -------------------------

# GUARDS

# -------------------------

if ! command -v mega-put >/dev/null 2>&1; then

  echo "MEGA CMD NOT FOUND (install megacmd)"

  exit 1

fi

if [ ! -d "$BACKUP_DIR" ]; then

  echo "NO BACKUP DIR FOUND"

  exit 1

fi

# -------------------------

# FREE TIER SAFETY LIMITS

# -------------------------

MAX_SIZE_MB=500

TOTAL_SIZE_MB=$(du -sm "$BACKUP_DIR" | awk '{print $1}')

echo "BACKUP SIZE: ${TOTAL_SIZE_MB}MB"

if [ "$TOTAL_SIZE_MB" -gt "$MAX_SIZE_MB" ]; then

  echo "ABORT: EXCEEDS FREE TIER SAFE LIMIT (${MAX_SIZE_MB}MB)"

  exit 1

fi

# -------------------------

# SYNC (RATE LIMITED STRATEGY)

# -------------------------

echo "UPLOADING TO MEGA OFFSITE..."

# upload only newest files first (cost-aware / bandwidth-aware)

find "$BACKUP_DIR" -type f -name "*.tar.gz" -o -name "*.bundle" | sort | tail -n 10 | while read -r f; do

  echo "UPLOAD: $f"

  mega-put "$f" "$MEGA_REMOTE/"

  sleep 2

done

echo "MEGA OFFSITE SYNC COMPLETE"

