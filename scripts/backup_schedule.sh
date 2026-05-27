
#!/usr/bin/env bash

set -e

echo "RUNNING SCHEDULED BACKUP PIPELINE..."

bash scripts/enterprise_backup.sh

bash scripts/backup_verify.sh

echo "SCHEDULE CYCLE COMPLETE"

