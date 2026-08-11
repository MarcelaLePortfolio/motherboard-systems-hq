#!/usr/bin/env bash
set -euo pipefail

VOLUME="/Volumes/Rio Drive"

echo "=== VERIFY RIO DRIVE EJECT STATE ==="

if [[ -e "$VOLUME" ]]; then
  echo "RIO_DRIVE_MOUNT_PATH=PRESENT"
  diskutil info "$VOLUME" 2>/dev/null | grep -E \
    'Device Identifier|Mounted|Volume Name' || true
  echo "SAFE_TO_PHYSICALLY_DISCONNECT=NO"
  exit 2
fi

if mount | grep -Fq "/Volumes/Rio Drive"; then
  echo "RIO_DRIVE_STILL_MOUNTED=YES"
  echo "SAFE_TO_PHYSICALLY_DISCONNECT=NO"
  exit 2
fi

echo "RIO_DRIVE_MOUNT_PATH=ABSENT"
echo "RIO_DRIVE_EJECTED=YES"
echo "SAFE_TO_PHYSICALLY_DISCONNECT=YES"
echo "NOTE=Previous diagnostics found no mounted Rio Drive path or open handles."
