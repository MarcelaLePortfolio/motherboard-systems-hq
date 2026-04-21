#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT=".runtime/docker_desktop_controlled_restart.txt"
SUMMARY="docs/phase487_docker_post_restart_summary.md"

log() {
  echo "$1" | tee -a "$OUT"
}

: > "$OUT"

log "PHASE 487 — DOCKER DESKTOP CONTROLLED RESTART"
log "DATE: $(date)"
log ""

log "== Pre-restart quick signals =="
python3 - << 'PY' | tee -a "$OUT"
import subprocess

checks = [
    ["docker", "context", "show"],
    ["docker", "version"],
    ["docker", "ps"],
    ["docker", "system", "df"],
]

for cmd in checks:
    print(f"---- {' '.join(cmd)} ----")
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
    print("")
PY

log "== Quitting Docker Desktop =="
osascript -e 'tell application "Docker Desktop" to quit' >/dev/null 2>&1 || true
pkill -f "Docker Desktop.app" >/dev/null 2>&1 || true
pkill -f "com.docker.backend" >/dev/null 2>&1 || true

python3 - << 'PY' | tee -a "$OUT"
import subprocess, time

deadline = time.time() + 45
while time.time() < deadline:
    p = subprocess.run(["pgrep", "-f", "Docker Desktop.app|com.docker.backend"],
                       capture_output=True, text=True)
    if p.returncode != 0:
        print("Docker Desktop processes stopped.")
        break
    time.sleep(2)
else:
    print("WARNING: Docker Desktop processes did not fully stop within 45s.")
PY

log ""
log "== Relaunching Docker Desktop =="
open -a Docker

python3 - << 'PY' | tee -a "$OUT"
import subprocess, time, sys

deadline = time.time() + 180
checks = [
    ["docker", "context", "show"],
    ["docker", "version"],
    ["docker", "ps"],
]

healthy = False
attempt = 0

while time.time() < deadline:
    attempt += 1
    print(f"Attempt {attempt}...")
    ok = True
    for cmd in checks:
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=12)
            if r.returncode != 0:
                ok = False
                print(f"FAIL {' '.join(cmd)} exit={r.returncode}")
                if r.stdout:
                    print(r.stdout, end="")
                if r.stderr:
                    print(r.stderr, end="")
                break
        except subprocess.TimeoutExpired:
            ok = False
            print(f"TIMEOUT {' '.join(cmd)}")
            break
    if ok:
        healthy = True
        print("Docker basic health checks passed.")
        break
    time.sleep(5)

if not healthy:
    print("Docker did not return to healthy basic state within 180s.")
    sys.exit(1)
PY

log ""
log "== Post-restart bounded probe =="
python3 - << 'PY' | tee -a "$OUT"
import subprocess

checks = [
    ["docker", "version"],
    ["docker", "info"],
    ["docker", "ps"],
    ["docker", "system", "df"],
]

for cmd in checks:
    print(f"---- {' '.join(cmd)} ----")
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
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
    print("")
PY

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/docker_desktop_controlled_restart.txt").read_text(errors="ignore")

signals = []
for line in txt.splitlines():
    lower = line.lower()
    if "timeout" in lower or " eof" in lower or lower.startswith("eof") or "retrieving disk usage: eof" in lower:
        signals.append(line)
    elif "exit=" in line:
        signals.append(line)

summary = []
summary.append("# Phase 487 Docker Post-Restart Summary")
summary.append("")
summary.append(f"Generated from `.runtime/docker_desktop_controlled_restart.txt` on restart attempt.")
summary.append("")
summary.append("## Key Signals")
summary.append("")
if signals:
    summary.append("```")
    summary.extend(signals[-80:])
    summary.append("```")
else:
    summary.append("No timeout/EOF/error signals captured.")
summary.append("")
summary.append("## Interpretation")
summary.append("")
if "retrieving disk usage: EOF" in txt or "\nEOF\nexit=1" in txt or "TIMEOUT docker info" in txt or "TIMEOUT docker ps" in txt:
    summary.append("- Docker remains partially unhealthy after restart attempt.")
    summary.append("- Storage classification should remain blocked.")
    summary.append("- Next corridor should be Docker Desktop backend/reset investigation, not prune.")
else:
    summary.append("- Docker basic commands recovered.")
    summary.append("- Safe to resume read-only storage classification next.")
Path("docs/phase487_docker_post_restart_summary.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_docker_post_restart_summary.md")
PY

sed -n '1,220p' "$SUMMARY"
