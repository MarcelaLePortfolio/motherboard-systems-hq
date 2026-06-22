
#!/usr/bin/env bash

set -euo pipefail

REPORT="snapshots-subdir-permission-diagnosis-$(date +%Y%m%d_%H%M%S).md"

TEST_SCRIPT="/tmp/test-snapshots-subdir-access.sh"

BACKUP_SCRIPT="$PWD/scripts/disaster-recovery/create-phase736-external-backup.sh"

SNAPROOT="/Volumes/Rio Drive/Motherboard_External_Backup/snapshots"

cat > "$TEST_SCRIPT" << 'INNER_EOF'

#!/bin/bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

DEST="/Volumes/Rio Drive/Motherboard_External_Backup/snapshots/launchagent_snapshots_test_$STAMP"

echo "USER=$(whoami)"

echo "DEST=$DEST"

mkdir -p "$DEST"

echo "hello from snapshots subdir test" > "$DEST/test.txt"

ls -la "$DEST"

rm -rf "$DEST"

INNER_EOF

chmod +x "$TEST_SCRIPT"

{

  echo "# Snapshots Subdir Permission Diagnosis"

  echo

  echo "Repo: $(git rev-parse --show-toplevel)"

  echo "Branch: $(git branch --show-current)"

  echo "HEAD: $(git rev-parse HEAD)"

  echo

  echo "## Snapshot Root"

  echo

  echo "$SNAPROOT"

  echo

  ls -ld "$SNAPROOT" || true

  echo

  echo "## Direct shell snapshots-subdir write"

  echo

  /bin/bash "$TEST_SCRIPT"

  echo

  echo "## launchctl asuser snapshots-subdir write"

  echo

  launchctl asuser "$(id -u)" /bin/bash "$TEST_SCRIPT"

  echo

  echo "## Direct backup script execution"

  echo

  /bin/bash "$BACKUP_SCRIPT"

  echo

  echo "## Latest external snapshots"

  echo

  ls -ltrh "$SNAPROOT" | tail -20 || true

  echo

  echo "## Backup LaunchAgent stderr tail"

  echo

  tail -80 logs/disaster-backup.err.log 2>/dev/null || true

} > "$REPORT" 2>&1

cat "$REPORT"

git add "$REPORT" diagnose-snapshots-subdir-permission.sh

git commit -m "Diagnose snapshots subdir backup permission"

git push

