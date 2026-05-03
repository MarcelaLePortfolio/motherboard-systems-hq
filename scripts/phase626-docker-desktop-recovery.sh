#!/usr/bin/env bash
set -euo pipefail

echo "Quitting Docker Desktop via macOS..."
osascript -e 'quit app "Docker"' || true
sleep 10

echo "Starting Docker Desktop..."
open -a Docker

echo "Waiting for Docker daemon..."
for i in {1..120}; do
  if docker info >/dev/null 2>&1; then
    echo "Docker daemon ready."
    docker version
    docker context ls
    docker ps
    exit 0
  fi
  echo "Waiting... $i"
  sleep 2
done

echo "Docker daemon still not ready after 4 minutes."
echo "Manual step likely needed: open Docker Desktop UI and check whether it is stuck starting."
exit 1
