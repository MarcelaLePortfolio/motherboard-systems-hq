
#!/usr/bin/env bash

set -u

echo "=== PHASE 746 EXTERNAL DR PROPAGATION VERIFICATION ==="

echo ""

echo "=== REPO STATUS ==="

git status

echo ""

echo "=== CURRENT COMMIT ==="

git rev-parse --short HEAD

echo ""

echo "=== INTERNAL PHASE 746 DR SNAPSHOT ==="

find DISASTER_RECOVERY/phase-746-seal -maxdepth 2 -type f \( -name "SNAPSHOT_MANIFEST.txt" -o -name "phase-746-seal.tar.gz" -o -name "phase-746-seal.sha256" \) -print | sort

echo ""

echo "=== INTERNAL SNAPSHOT CHECKSUM ==="

find DISASTER_RECOVERY/phase-746-seal -name "phase-746-seal.sha256" -print -exec cat {} \;

echo ""

echo "=== EXTERNAL DRIVE MOUNT CHECK ==="

if [ -d "/Volumes/Rio Drive" ]; then

  echo "Rio Drive mounted."

else

  echo "Rio Drive NOT mounted."

fi

echo ""

echo "=== EXTERNAL SNAPSHOT SEARCH ==="

find "/Volumes/Rio Drive/Motherboard_Storage/snapshots" -maxdepth 4 \( -iname "*phase746*" -o -iname "*phase-746*" -o -iname "*746*" \) -print 2>/dev/null | sort || true

echo ""

echo "=== LATEST EXTERNAL SNAPSHOTS ==="

ls -lt "/Volumes/Rio Drive/Motherboard_Storage/snapshots" 2>/dev/null | head -20 || true

echo ""

echo "=== VERIFICATION COMPLETE ==="

