#!/usr/bin/env bash
set -euo pipefail

echo "==> quitting Docker Desktop"
osascript -e 'quit app "Docker"' || true
sleep 3

echo "==> stopping lingering Docker processes"
pkill -x Docker || true
pkill -x "Docker Desktop" || true
pkill -f com.docker.backend || true
pkill -f vpnkit || true
pkill -f containerd || true
sleep 3

echo "==> relaunching Docker Desktop"
open -a Docker

echo "==> waiting for Docker socket"
for _ in $(seq 1 90); do
  if docker version >/tmp/phase61_docker_version.out 2>/tmp/phase61_docker_version.err; then
    break
  fi
  sleep 2
done

echo "==> probing Docker server"
if docker info >/tmp/phase61_docker_info.out 2>/tmp/phase61_docker_info.err; then
  echo "Docker server recovered."
  cat /tmp/phase61_docker_info.out
  exit 0
fi

echo "Docker server still unhealthy."
echo
echo "docker version stderr:"
cat /tmp/phase61_docker_version.err || true
echo
echo "docker info stderr:"
cat /tmp/phase61_docker_info.err || true
echo
echo "Next manual step:"
echo "Docker Desktop -> Troubleshoot -> Restart Docker Desktop"
echo "If that fails: Docker Desktop -> Troubleshoot -> Clean / Purge data"
exit 1
