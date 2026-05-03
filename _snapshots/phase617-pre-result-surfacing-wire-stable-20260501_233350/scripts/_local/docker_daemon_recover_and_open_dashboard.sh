#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="$ROOT/docs/DOCKER_DAEMON_RECOVERY_$STAMP.txt"

{
  echo "DOCKER DAEMON RECOVERY"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo
  echo "STEP 1 — CHECK DOCKER"
  docker info >/dev/null 2>&1 && echo "Docker daemon already running" || echo "Docker daemon not running"
  echo
  echo "STEP 2 — START DOCKER DESKTOP"
  open -a Docker || true
  echo "Docker Desktop launch requested"
  echo
  echo "STEP 3 — WAIT FOR DOCKER DAEMON"
  for i in $(seq 1 60); do
    if docker info >/dev/null 2>&1; then
      echo "Docker daemon ready after ${i}s"
      break
    fi
    sleep 1
  done
  docker info >/dev/null 2>&1
  echo
  echo "STEP 4 — COMPOSE STATUS BEFORE START"
  docker compose ps || true
  echo
  echo "STEP 5 — START DASHBOARD STACK"
  docker compose up -d
  echo
  echo "STEP 6 — COMPOSE STATUS AFTER START"
  docker compose ps
  echo
  echo "STEP 7 — HTTP CHECKS"
  curl -I http://localhost:8080 || true
  curl -I http://localhost:3000 || true
} | tee "$OUT"

open http://localhost:8080 || true
