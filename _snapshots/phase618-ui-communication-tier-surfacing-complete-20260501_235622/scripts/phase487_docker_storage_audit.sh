#!/bin/bash

set -e

echo "🔍 PHASE 487 — DOCKER STORAGE CLASSIFICATION (READ-ONLY)"
echo "------------------------------------------------------"

echo ""
echo "📦 Docker System Overview:"
docker system df

echo ""
echo "📦 Detailed Disk Usage (verbose):"
docker system df -v

echo ""
echo "📁 Listing Docker Volumes:"
docker volume ls

echo ""
echo "📁 Inspecting Volumes (metadata only):"
for vol in $(docker volume ls -q); do
  echo "---- Volume: $vol ----"
  docker volume inspect $vol | grep -E '"Name"|"Mountpoint"|"Driver"'
done

echo ""
echo "🧱 Listing Images:"
docker images

echo ""
echo "📦 Listing Containers (all):"
docker ps -a

echo ""
echo "🧪 Container Size Breakdown:"
docker ps -a --size

echo ""
echo "📂 Overlay2 Directory Size (if exists):"
if [ -d "/var/lib/docker/overlay2" ]; then
  sudo du -sh /var/lib/docker/overlay2
else
  echo "overlay2 directory not accessible or not present"
fi

echo ""
echo "📂 Docker Root Directory Size:"
sudo du -sh /var/lib/docker || echo "No permission or path unavailable"

echo ""
echo "✅ Classification audit complete (NO MUTATIONS PERFORMED)"
