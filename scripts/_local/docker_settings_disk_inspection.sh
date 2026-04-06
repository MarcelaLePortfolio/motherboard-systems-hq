#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/docker_settings_disk_inspection_${STAMP}.txt"

{
echo "DOCKER SETTINGS DISK INSPECTION"
echo "Timestamp: $(date)"
echo
echo "SAFETY POSTURE"
echo "- Read-only inspection only."
echo "- No deletion."
echo "- No Docker data mutation."
echo "- No application code mutation."
echo

echo "==== CANDIDATE SETTINGS FILES ===="
find "$HOME/Library/Group Containers" "$HOME/Library/Containers/com.docker.docker" "$HOME/.docker" \
  -maxdepth 4 \
  \( -name '*.json' -o -name '*.plist' -o -name 'settings-store.json' -o -name 'settings.json' -o -name 'daemon.json' \) \
  2>/dev/null | sort || true
echo

echo "==== GREP FOR DISK / VM / RESOURCE KEYS ===="
find "$HOME/Library/Group Containers" "$HOME/Library/Containers/com.docker.docker" "$HOME/.docker" \
  -maxdepth 4 \
  -type f \
  \( -name '*.json' -o -name '*.plist' -o -name 'settings-store.json' -o -name 'settings.json' -o -name 'daemon.json' \) \
  -print0 2>/dev/null | xargs -0 grep -HnEi 'disk|DiskSize|diskSize|MiB|GiB|virtualization|vm|memory|cpu|resources' 2>/dev/null || true
echo

echo "==== COMMON DOCKER SETTINGS FILE CONTENTS ===="
for f in \
  "$HOME/Library/Group Containers/group.com.docker/settings-store.json" \
  "$HOME/Library/Group Containers/group.com.docker/settings.json" \
  "$HOME/Library/Containers/com.docker.docker/Data/settings.json" \
  "$HOME/.docker/daemon.json"
do
  if [ -f "$f" ]; then
    echo "---- $f ----"
    cat "$f"
    echo
  fi
done

echo "==== DOCKER RAW FILE ===="
ls -lh "$HOME/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw" 2>/dev/null || true
du -sh "$HOME/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw" 2>/dev/null || true
echo

echo "==== INTERPRETATION BOUNDARY ===="
echo "This inspection is for determining whether Docker Desktop disk allocation"
echo "is the blocker. It does not change Docker settings."
echo

} > "$OUT"

echo "Inspection written to:"
echo "$OUT"

echo
echo "----- INSPECTION PREVIEW -----"
sed -n '1,320p' "$OUT"
