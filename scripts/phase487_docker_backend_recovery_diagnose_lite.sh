#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/docker_backend_recovery_diagnose_lite.txt"
OUT_MD="docs/phase487_docker_backend_recovery_summary.md"

{
  echo "🔎 PHASE 487 — DOCKER BACKEND RECOVERY (LITE)"
  echo "DATE: $(date)"
  echo ""

  echo "---- docker context show ----"
  docker context show || true
  echo ""

  echo "---- docker version (10s bounded) ----"
  timeout 10 docker version || echo "TIMEOUT docker version"
  echo ""

  echo "---- docker info (10s bounded) ----"
  timeout 10 docker info || echo "TIMEOUT docker info"
  echo ""

  echo "---- docker ps (10s bounded) ----"
  timeout 10 docker ps || echo "TIMEOUT docker ps"
  echo ""

  echo "---- docker system df (10s bounded) ----"
  timeout 10 docker system df || echo "TIMEOUT docker system df"
  echo ""

  echo "---- socket ----"
  ls -l /Users/marcela-dev/.docker/run/docker.sock || true
  echo ""

  echo "---- docker processes (top 10) ----"
  ps aux | grep -i "[d]ocker" | head -n 10 || true
  echo ""

  echo "---- host log quick scan ----"
  grep -iE "error|fatal|panic|timeout|eof|disk|overlay|daemon" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host"/* 2>/dev/null | tail -n 50 || true
  echo ""

  echo "---- vm log quick scan ----"
  grep -iE "error|fatal|panic|timeout|eof|disk|overlay|daemon" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/vm"/* 2>/dev/null | tail -n 50 || true
  echo ""
} > "$OUT_TXT"

{
  echo "# Phase 487 Docker Backend Recovery Summary (Lite)"
  echo ""
  echo "Generated: $(date)"
  echo ""
  echo "## Key Signals"
  echo ""
  grep -E "TIMEOUT|error|fatal|panic|EOF" "$OUT_TXT" | tail -n 40 || echo "No critical signals found"
  echo ""
  echo "## Status"
  echo "- If TIMEOUT present → daemon unresponsive"
  echo "- If EOF/disk errors → storage layer unstable"
  echo "- If no errors → safe to proceed to controlled restart next step"
} > "$OUT_MD"

echo "Wrote $OUT_MD"
