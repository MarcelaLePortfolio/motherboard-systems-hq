
#!/usr/bin/env bash

set -euo pipefail

echo "RUNNING DR PREFLIGHT CHECK..."

REQUIRED_SCRIPTS=(

  "scripts/enterprise_backup.sh"

  "scripts/backup_verify.sh"

  "scripts/backup_health_check.sh"

  "scripts/external_backup_sync.sh"

  "scripts/disk_monitor.sh"

)

FAIL=0

for f in "${REQUIRED_SCRIPTS[@]}"; do

  if [ ! -f "$f" ]; then

    echo "MISSING: $f"

    FAIL=1

  fi

done

if [ "$FAIL" -eq 1 ]; then

  echo "DR SYSTEM STATE: NOT SAFE TO RUN"

  exit 1

fi

echo "DR PREFLIGHT: PASSED"

