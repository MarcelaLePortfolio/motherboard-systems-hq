#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT=".runtime/docker_desktop_force_recover.txt"
SUMMARY="docs/phase487_docker_force_recover_summary.md"

: > "$OUT"

log() {
  echo "$1" | tee -a "$OUT"
}

log "PHASE 487 — DOCKER DESKTOP FORCE RECOVERY (SAFE CORRIDOR)"
log "DATE: $(date)"
log ""

log "== Step 1: Force kill all Docker-related processes =="
pkill -9 -f "Docker Desktop" >/dev/null 2>&1 || true
pkill -9 -f "com.docker.backend" >/dev/null 2>&1 || true
pkill -9 -f "com.docker.hyperkit" >/dev/null 2>&1 || true
pkill -9 -f "com.docker.vpnkit" >/dev/null 2>&1 || true
pkill -9 -f "docker" >/dev/null 2>&1 || true

sleep 3

log "Checking for lingering processes..."
pgrep -fl docker || echo "No docker processes running"

log ""
log "== Step 2: Check Docker socket =="
ls -l /Users/marcela-dev/.docker/run/docker.sock || echo "Socket missing"

log ""
log "== Step 3: Relaunch Docker Desktop =="
open -a Docker || true

log "Waiting for app process to appear..."
python3 - << 'PY' | tee -a "$OUT"
import subprocess, time

deadline = time.time() + 60
while time.time() < deadline:
    p = subprocess.run(["pgrep", "-f", "Docker Desktop.app"],
                       capture_output=True, text=True)
    if p.returncode == 0:
        print("Docker Desktop process detected.")
        break
    time.sleep(2)
else:
    print("Docker Desktop process did NOT appear within 60s.")
PY

log ""
log "== Step 4: Basic CLI check (bounded) =="
python3 - << 'PY' | tee -a "$OUT"
import subprocess

cmds = [
    ["docker", "version"],
    ["docker", "ps"]
]

for cmd in cmds:
    print(f"---- {' '.join(cmd)} ----")
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        if r.stdout:
            print(r.stdout, end="")
        if r.stderr:
            print(r.stderr, end="")
        print(f"exit={r.returncode}")
    except subprocess.TimeoutExpired:
        print("TIMEOUT")
        print("exit=124")
    print("")
PY

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/docker_desktop_force_recover.txt").read_text(errors="ignore")

summary = []
summary.append("# Phase 487 Docker Force Recover Summary")
summary.append("")
summary.append("## Result")
summary.append("")

if "did NOT appear" in txt:
    summary.append("- Docker Desktop failed to relaunch.")
    summary.append("- Likely corrupted install or stuck system state.")
    summary.append("- Next step: clean reinstall (guided).")
elif "Cannot connect to the Docker daemon" in txt:
    summary.append("- Docker Desktop launched but daemon still unhealthy.")
    summary.append("- Next step: backend reset (non-destructive first).")
else:
    summary.append("- Docker Desktop appears to be recovering.")
    summary.append("- Re-run diagnostics before any storage actions.")

Path("docs/phase487_docker_force_recover_summary.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_docker_force_recover_summary.md")
PY

sed -n '1,120p' "$SUMMARY"
