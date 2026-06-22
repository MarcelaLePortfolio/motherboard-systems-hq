
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

DAEMON="scripts/dr_daemon_self_healing.sh"

while true; do

  if ! pgrep -f "$DAEMON" > /dev/null; then

    echo "[$(date)] DAEMON DOWN → RESTARTING"

    nohup bash "$ROOT_DIR/$DAEMON" >> /dev/null 2>&1 &

  fi

  sleep 30

done

