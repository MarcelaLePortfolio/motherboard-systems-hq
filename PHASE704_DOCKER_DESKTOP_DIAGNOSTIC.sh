#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Docker Desktop diagnostic gate"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Disk state..."
df -h /
df -h /System/Volumes/Data

echo ""
echo "3) Docker CLI location/version..."
which docker || true
docker --version || true
docker compose version || true

echo ""
echo "4) Docker contexts..."
docker context ls || true
docker context show || true

echo ""
echo "5) Docker socket paths..."
ls -la "$HOME/.docker" || true
ls -la "$HOME/.docker/run" || true
ls -la /var/run/docker.sock || true

echo ""
echo "6) Docker Desktop app/process state..."
osascript -e 'tell application "System Events" to get name of every process whose name contains "Docker"' || true
ps aux | grep -i '[D]ocker' || true
ps aux | grep -i '[c]om.docker' || true

echo ""
echo "7) Docker Desktop app bundle check..."
ls -ld /Applications/Docker.app || true
mdfind 'kMDItemCFBundleIdentifier == "com.docker.docker"' || true

echo ""
echo "8) Docker Desktop log tail candidates..."
for f in \
  "$HOME/Library/Containers/com.docker.docker/Data/log/host/com.docker.backend.log" \
  "$HOME/Library/Containers/com.docker.docker/Data/log/host/Docker Desktop.log" \
  "$HOME/Library/Group Containers/group.com.docker/DockerAppStderr.txt" \
  "$HOME/Library/Group Containers/group.com.docker/DockerAppStdout.txt"
do
  if [ -f "$f" ]; then
    echo ""
    echo "---- $f ----"
    tail -n 80 "$f" || true
  fi
done

echo ""
echo "9) Current Docker daemon probe..."
if docker info >/tmp/phase704_docker_info_diag.txt 2>/tmp/phase704_docker_info_diag.err; then
  echo "Docker daemon: HEALTHY"
  sed -n '1,80p' /tmp/phase704_docker_info_diag.txt
else
  echo "Docker daemon: UNHEALTHY"
  cat /tmp/phase704_docker_info_diag.err || true
fi

echo ""
echo "Diagnostic complete. Do not rebuild containers until docker info succeeds."
