
#!/usr/bin/env bash

set -euo pipefail

echo "RUNNING STORAGE MONITOR"

bash scripts/storage_monitor.sh

echo "CHECKING POLICY"

set +e

bash scripts/storage_policy.sh

POLICY_CODE=$?

set -e

if [ "$POLICY_CODE" -eq 2 ]; then

  echo "CRITICAL STORAGE STATE → RUNNING RETENTION"

  bash scripts/retention_engine.sh

fi

echo "RUNNING BACKUP PIPELINE"

bash scripts/full_dr_pipeline.sh

echo "AUTONOMOUS CYCLE COMPLETE"

