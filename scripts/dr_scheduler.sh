
#!/usr/bin/env bash

set -euo pipefail

echo "RUNNING DR SCHEDULER LAYER..."

CRON_JOB="0 */6 * * * cd $(pwd) && bash scripts/full_dr_pipeline.sh >> logs/dr.log 2>&1"

echo "PROPOSED CRON:"

echo "$CRON_JOB"

echo ""

echo "INSTALLING LOCAL CRON (USER LEVEL)..."

( crontab -l 2>/dev/null; echo "$CRON_JOB" ) | sort -u | crontab -

echo "DR SCHEDULER ACTIVE: EVERY 6 HOURS"

