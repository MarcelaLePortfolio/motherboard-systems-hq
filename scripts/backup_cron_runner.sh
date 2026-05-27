
#!/usr/bin/env bash

set -e

echo "RUNNING FULL DISASTER RECOVERY PIPELINE..."

bash scripts/enterprise_backup.sh

bash scripts/backup_verify.sh

bash scripts/external_backup_sync.sh

echo "FULL BACKUP CYCLE COMPLETE"

