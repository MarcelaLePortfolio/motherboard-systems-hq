
#!/usr/bin/env bash

set -euo pipefail

echo "ENFORCING FAIL-FAST DR POLICY..."

FAIL=0

# External drive MUST exist

if [ ! -d "/Volumes/EXTERNAL_BACKUP_DRIVE" ]; then

  echo "CRITICAL: EXTERNAL DRIVE MISSING"

  FAIL=1

fi

# Backup directory MUST exist

if [ ! -d "./backups" ]; then

  echo "CRITICAL: BACKUP DIRECTORY MISSING"

  FAIL=1

fi

# DR logs MUST exist after execution window

if [ -f "logs/dr.log" ]; then

  ERRORS=$(grep -i "error\|fail" logs/dr.log || true)

  if [ -n "$ERRORS" ]; then

    echo "CRITICAL: DR FAILURE EVENTS DETECTED"

    FAIL=1

  fi

fi

if [ "$FAIL" -eq 1 ]; then

  echo "DR SYSTEM STATUS: FAILED (HARD STOP)"

  exit 1

fi

echo "DR FAIL-FAST POLICY: PASS"

