
#!/usr/bin/env bash

set -euo pipefail

echo "RUNNING FULL ENTERPRISE DR PIPELINE..."

bash scripts/enterprise_backup.sh

bash scripts/backup_verify.sh

bash scripts/backup_health_check.sh

bash scripts/disk_monitor.sh

bash scripts/external_backup_sync.sh

echo "DR PIPELINE COMPLETE: ALL SYSTEMS NOMINAL"

