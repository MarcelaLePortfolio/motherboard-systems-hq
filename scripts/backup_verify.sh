
#!/usr/bin/env bash

set -e

BACKUP_DIR="./backups"

echo "VERIFYING BACKUPS..."

for file in "$BACKUP_DIR"/*; do

  if [ -f "$file" ]; then

    sha256sum "$file"

  fi

done

echo "VERIFICATION COMPLETE"

