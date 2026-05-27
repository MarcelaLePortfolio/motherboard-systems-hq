
#!/usr/bin/env bash

set -euo pipefail

THRESHOLD=85

USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')

echo "DISK USAGE: ${USAGE}%"

if [ "$USAGE" -ge "$THRESHOLD" ]; then

  echo "WARNING: DISK SPACE CRITICAL - CLEANUP REQUIRED"

fi

