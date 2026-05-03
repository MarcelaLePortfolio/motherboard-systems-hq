#!/bin/bash

echo "🛠️ SAFE DOCKER DESKTOP REPAIR (NO PROJECT DATA LOSS)"
echo ""

echo "Step 1: Fully quitting Docker..."
osascript -e 'quit app "Docker"'
sleep 5

echo "Step 2: Stopping privileged helper (requires password)..."
sudo launchctl unload /Library/LaunchDaemons/com.docker.vmnetd.plist 2>/dev/null || true
sleep 3

echo "Step 3: Clearing ONLY runtime state (NOT images/volumes)..."
rm -rf ~/Library/Containers/com.docker.docker/Data/backend.sock 2>/dev/null || true
rm -rf ~/.docker/run 2>/dev/null || true

echo "Step 4: Restarting helper..."
sudo launchctl load /Library/LaunchDaemons/com.docker.vmnetd.plist 2>/dev/null || true
sleep 3

echo "Step 5: Starting Docker Desktop..."
open -a Docker

echo ""
echo "⏳ Waiting for Docker daemon..."

for i in {1..36}; do
  if docker info >/dev/null 2>&1; then
    echo "✅ Docker daemon is ready."
    exit 0
  fi

  echo "Waiting... ($i/36)"
  sleep 5
done

echo ""
echo "❌ Docker still not ready after safe repair."
echo "Next step would be Docker Desktop UI 'Restart' (not factory reset)."
