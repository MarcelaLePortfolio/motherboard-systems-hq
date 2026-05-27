
#!/usr/bin/env bash

set -euo pipefail

BACKUP_ROOT="./backups"

echo "RUNNING BACKUP HEALTH CHECK..."

LATEST_BUNDLE=$(ls -t "$BACKUP_ROOT"/repo_*.bundle 2>/dev/null | head -n 1 || true)

LATEST_TAR=$(ls -t "$BACKUP_ROOT"/source_*.tar.gz 2>/dev/null | head -n 1 || true)

if [ -z "${LATEST_BUNDLE:-}" ] || [ -z "${LATEST_TAR:-}" ]; then

  echo "HEALTH FAIL: Missing backup artifacts"

  exit 1

fi

echo "LATEST BUNDLE: $LATEST_BUNDLE"

echo "LATEST ARCHIVE: $LATEST_TAR"

echo "HEALTH CHECK COMPLETE"

