#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/docker_backend_recovery_diagnose.txt"
OUT_MD="docs/phase487_docker_backend_recovery_summary.md"

{
  echo "🔎 PHASE 487 — DOCKER BACKEND RECOVERY DIAGNOSIS (READ-ONLY)"
  echo "==========================================================="
  echo "DATE: $(date)"
  echo "PWD: $(pwd)"
  echo ""

  echo "---- docker context show ----"
  docker context show || true
  echo ""

  echo "---- docker version (20s bounded) ----"
  python3 - << 'PY'
import subprocess
cmd = ["docker", "version"]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
    print(r.stdout, end="")
    print(r.stderr, end="")
    print(f"exit={r.returncode}")
except subprocess.TimeoutExpired as e:
    if e.stdout:
        print(e.stdout.decode() if isinstance(e.stdout, bytes) else e.stdout, end="")
    if e.stderr:
        print(e.stderr.decode() if isinstance(e.stderr, bytes) else e.stderr, end="")
    print("exit=124")
    print("TIMEOUT: docker version did not complete within 20s")
PY
  echo ""

  echo "---- docker info (20s bounded) ----"
  python3 - << 'PY'
import subprocess
cmd = ["docker", "info"]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
    print(r.stdout, end="")
    print(r.stderr, end="")
    print(f"exit={r.returncode}")
except subprocess.TimeoutExpired as e:
    if e.stdout:
        print(e.stdout.decode() if isinstance(e.stdout, bytes) else e.stdout, end="")
    if e.stderr:
        print(e.stderr.decode() if isinstance(e.stderr, bytes) else e.stderr, end="")
    print("exit=124")
    print("TIMEOUT: docker info did not complete within 20s")
PY
  echo ""

  echo "---- docker ps (20s bounded) ----"
  python3 - << 'PY'
import subprocess
cmd = ["docker", "ps"]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
    print(r.stdout, end="")
    print(r.stderr, end="")
    print(f"exit={r.returncode}")
except subprocess.TimeoutExpired as e:
    if e.stdout:
        print(e.stdout.decode() if isinstance(e.stdout, bytes) else e.stdout, end="")
    if e.stderr:
        print(e.stderr.decode() if isinstance(e.stderr, bytes) else e.stderr, end="")
    print("exit=124")
    print("TIMEOUT: docker ps did not complete within 20s")
PY
  echo ""

  echo "---- docker system df (20s bounded) ----"
  python3 - << 'PY'
import subprocess
cmd = ["docker", "system", "df"]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
    print(r.stdout, end="")
    print(r.stderr, end="")
    print(f"exit={r.returncode}")
except subprocess.TimeoutExpired as e:
    if e.stdout:
        print(e.stdout.decode() if isinstance(e.stdout, bytes) else e.stdout, end="")
    if e.stderr:
        print(e.stderr.decode() if isinstance(e.stderr, bytes) else e.stderr, end="")
    print("exit=124")
    print("TIMEOUT: docker system df did not complete within 20s")
PY
  echo ""

  echo "---- docker socket ----"
  ls -l /Users/marcela-dev/.docker/run/docker.sock || true
  echo ""

  echo "---- docker processes ----"
  ps aux | grep -i "[d]ocker" || true
  echo ""

  echo "---- docker host logs (latest 120 matching lines) ----"
  find "$HOME/Library/Containers/com.docker.docker/Data/log/host" -type f 2>/dev/null | while read -r f; do
    echo "FILE: $f"
    grep -iE "error|fatal|panic|timeout|eof|disk|overlay|volume|df|engine|daemon|grpc|hang|stuck" "$f" 2>/dev/null | tail -120 || true
    echo ""
  done

  echo "---- docker vm logs (latest 120 matching lines) ----"
  find "$HOME/Library/Containers/com.docker.docker/Data/log/vm" -type f 2>/dev/null | while read -r f; do
    echo "FILE: $f"
    grep -iE "error|fatal|panic|timeout|eof|disk|overlay|volume|df|engine|daemon|grpc|hang|stuck" "$f" 2>/dev/null | tail -120 || true
    echo ""
  done
} | tee "$OUT_TXT"

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/docker_backend_recovery_diagnose.txt").read_text(errors="ignore")
lines = txt.splitlines()

sections = {
    "docker_version": [],
    "docker_info": [],
    "docker_ps": [],
    "docker_df": [],
    "host_log_hits": [],
    "vm_log_hits": [],
}

current = None
for line in lines:
    if line.startswith("---- docker version"):
        current = "docker_version"; continue
    if line.startswith("---- docker info"):
        current = "docker_info"; continue
    if line.startswith("---- docker ps"):
        current = "docker_ps"; continue
    if line.startswith("---- docker system df"):
        current = "docker_df"; continue
    if line.startswith("---- docker host logs"):
        current = "host_log_hits"; continue
    if line.startswith("---- docker vm logs"):
        current = "vm_log_hits"; continue
    if line.startswith("---- "):
        current = None
    if current:
        sections[current].append(line)

def trimmed(block, n=60):
    block = [x for x in block if x.strip()]
    return block[:n]

summary = []
summary.append("# Phase 487 Docker Backend Recovery Summary")
summary.append("")
summary.append("Generated from `.runtime/docker_backend_recovery_diagnose.txt`.")
summary.append("")
summary.append("## Command Health")
summary.append("")
for key, title in [
    ("docker_version", "docker version"),
    ("docker_info", "docker info"),
    ("docker_ps", "docker ps"),
    ("docker_df", "docker system df"),
]:
    summary.append(f"### {title}")
    block = trimmed(sections[key], 80)
    if block:
        summary.append("```")
        summary.extend(block)
        summary.append("```")
    else:
        summary.append("_No captured output._")
    summary.append("")

summary.append("## Log Signals")
summary.append("")
for key, title in [
    ("host_log_hits", "Host log matches"),
    ("vm_log_hits", "VM log matches"),
]:
    summary.append(f"### {title}")
    block = trimmed(sections[key], 120)
    if block:
        summary.append("```")
        summary.extend(block)
        summary.append("```")
    else:
        summary.append("_No matching lines found._")
    summary.append("")

Path("docs/phase487_docker_backend_recovery_summary.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_docker_backend_recovery_summary.md")
PY
