
#!/usr/bin/env bash

set -euo pipefail

EXTERNAL="/Volumes/Rio Drive"

MIN_FREE_GB=50

MAX_USED_PERCENT=85

AVAIL_GB=$(df -g "$EXTERNAL" | awk 'NR==2 {print $4}')

PCT=$(df -H "$EXTERNAL" | awk 'NR==2 {print $5}' | sed 's/%//')

echo "AVAIL_GB=$AVAIL_GB"

echo "USED_PERCENT=$PCT"

if [ "$PCT" -ge "$MAX_USED_PERCENT" ] || [ "$AVAIL_GB" -le "$MIN_FREE_GB" ]; then

  echo "POLICY=CRITICAL"

  exit 2

fi

echo "POLICY=OK"

exit 0

