
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_ROOT="$ROOT_DIR/backups"

RESTORE_DIR="$ROOT_DIR/restore_test"

LATEST=$(ls -t "$BACKUP_ROOT"/source_*.tar.gz 2>/dev/null | head -n 1)

if [ -z "${LATEST:-}" ]; then

  echo "NO BACKUP FOUND"

  exit 1

fi

rm -rf "$RESTORE_DIR"

mkdir -p "$RESTORE_DIR"

tar -xzf "$LATEST" -C "$RESTORE_DIR"

echo "RESTORE COMPLETE: $LATEST"

