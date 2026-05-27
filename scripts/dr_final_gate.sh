
#!/usr/bin/env bash

set -euo pipefail

echo "RUNNING FINAL DR GATE (SYSTEM-WIDE VALIDATION)..."

bash scripts/dr_preflight_check.sh

bash scripts/backup_health_check.sh

bash scripts/disk_monitor.sh

bash scripts/dr_alerting.sh

echo "CHECKING EXTERNAL SYNC READINESS..."

if [ ! -d "/Volumes/EXTERNAL_BACKUP_DRIVE" ]; then

  echo "CRITICAL: EXTERNAL BACKUP LAYER DOWN"

  exit 1

fi

echo "DR FINAL GATE: ALL SYSTEMS VERIFIED"

echo "STATUS: PRODUCTION READY"

