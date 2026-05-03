#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/docker_backend_recovery_diagnose_lite.txt"
OUT_MD="docs/phase487_docker_backend_recovery_summary.md"

run_bounded() {
  local label="$1"
  shift
  echo "---- ${label} ----"
  python3 - "$@" << 'PY'
import subprocess
import sys

cmd = sys.argv[1:]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
    if r.stdout:
        print(r.stdout, end="")
    if r.stderr:
        print(r.stderr, end="")
    print(f"exit={r.returncode}")
except subprocess.TimeoutExpired as e:
    if e.stdout:
        try:
            print(e.stdout.decode() if isinstance(e.stdout, bytes) else e.stdout, end="")
        except Exception:
            pass
    if e.stderr:
        try:
            print(e.stderr.decode() if isinstance(e.stderr, bytes) else e.stderr, end="")
        except Exception:
            pass
    print("exit=124")
    print(f"TIMEOUT {' '.join(cmd)}")
PY
  echo ""
}

{
  echo "🔎 PHASE 487 — DOCKER BACKEND RECOVERY (LITE)"
  echo "DATE: $(date)"
  echo ""

  echo "---- docker context show ----"
  docker context show || true
  echo ""

  run_bounded "docker version (10s bounded)" docker version
  run_bounded "docker info (10s bounded)" docker info
  run_bounded "docker ps (10s bounded)" docker ps
  run_bounded "docker system df (10s bounded)" docker system df

  echo "---- socket ----"
  ls -l /Users/marcela-dev/.docker/run/docker.sock || true
  echo ""

  echo "---- docker processes (top 10) ----"
  ps aux | grep -i "[d]ocker" | head -n 10 || true
  echo ""

  echo "---- host log quick scan ----"
  find "$HOME/Library/Containers/com.docker.docker/Data/log/host" -type f -maxdepth 1 2>/dev/null \
    | while read -r f; do
        grep -iE "error|fatal|panic|timeout|eof|disk|overlay|daemon" "$f" 2>/dev/null || true
      done | tail -n 50
  echo ""

  echo "---- vm log quick scan ----"
  find "$HOME/Library/Containers/com.docker.docker/Data/log/vm" -type f -maxdepth 1 2>/dev/null \
    | while read -r f; do
        grep -iE "error|fatal|panic|timeout|eof|disk|overlay|daemon" "$f" 2>/dev/null || true
      done | tail -n 50
  echo ""
} > "$OUT_TXT"

{
  echo "# Phase 487 Docker Backend Recovery Summary (Lite)"
  echo ""
  echo "Generated: $(date)"
  echo ""
  echo "## Key Signals"
  echo ""
  grep -E "TIMEOUT|error|fatal|panic|EOF|exit=124|retrieving disk usage: EOF" "$OUT_TXT" | tail -n 40 || echo "No critical signals found"
  echo ""
  echo "## Status"
  echo "- If TIMEOUT present -> daemon unresponsive"
  echo "- If EOF/disk errors present -> storage layer unstable"
  echo "- If both are absent -> safe to proceed to controlled restart diagnosis"
  echo ""
  echo "## Command Health Snapshot"
  echo ""
  awk '
    /---- docker version \(10s bounded\) ----/ {flag=1}
    /---- docker info \(10s bounded\) ----/ {flag=1}
    /---- docker ps \(10s bounded\) ----/ {flag=1}
    /---- docker system df \(10s bounded\) ----/ {flag=1}
    flag {print}
    /exit=/ && flag {flag=0; print ""}
  ' "$OUT_TXT" | sed -n '1,120p'
} > "$OUT_MD"

echo "Wrote $OUT_MD"
sed -n '1,160p' "$OUT_MD"
