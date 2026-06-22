
#!/usr/bin/env bash

set -euo pipefail

EXTERNAL="/Volumes/Rio Drive"

if [ ! -d "$EXTERNAL" ]; then

  echo "STATE=NO_DRIVE"

  exit 0

fi

TOTAL=$(df -H "$EXTERNAL" | awk 'NR==2 {print $2}')

USED=$(df -H "$EXTERNAL" | awk 'NR==2 {print $3}')

AVAIL=$(df -H "$EXTERNAL" | awk 'NR==2 {print $4}')

PCT=$(df -H "$EXTERNAL" | awk 'NR==2 {print $5}' | sed 's/%//')

echo "STATE=OK"

echo "TOTAL=$TOTAL"

echo "USED=$USED"

echo "AVAILABLE=$AVAIL"

echo "USED_PERCENT=$PCT"

