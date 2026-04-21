#!/bin/bash

set +e

mkdir -p .runtime
OUT=".runtime/docker_health_probe_timeout.txt"

run_probe() {
  local label="$1"
  shift

  echo "---- ${label} ----"
  "$@"
  local status=$?
  echo "exit=${status}"
  echo ""
}

{
  echo "🔎 PHASE 487 — DOCKER HEALTH PROBE (TIME-BOUNDED, READ-ONLY)"
  echo "============================================================"
  echo "PWD: $(pwd)"
  echo "DATE: $(date)"
  echo ""

  run_probe "which docker" which docker
  run_probe "docker context show" docker context show
  run_probe "docker context inspect desktop-linux" docker context inspect desktop-linux

  echo "---- docker version (time-bounded) ----"
  python3 - << 'PY'
import subprocess
cmd = ["docker", "version"]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
    print(r.stdout, end="")
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
    print("TIMEOUT: docker version did not complete within 15s")
PY
  echo ""

  echo "---- docker info (time-bounded) ----"
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
    print("TIMEOUT: docker info did not complete within 20s")
PY
  echo ""

  echo "---- docker ps (time-bounded) ----"
  python3 - << 'PY'
import subprocess
cmd = ["docker", "ps"]
try:
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
    print(r.stdout, end="")
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
    print("TIMEOUT: docker ps did not complete within 15s")
PY
  echo ""

  echo "---- docker system df (time-bounded) ----"
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
    print("TIMEOUT: docker system df did not complete within 20s")
PY
  echo ""

  run_probe "docker desktop processes" ps aux
  echo "---- filtered docker processes ----"
  ps aux | grep -i "[d]ocker"
  echo "exit=$?"
  echo ""

  echo "---- docker socket visibility ----"
  ls -l /Users/marcela-dev/.docker/run/docker.sock
  echo "exit=$?"
  echo ""

  echo "---- recent Docker Desktop logs (if present) ----"
  ls -1t "$HOME/Library/Containers/com.docker.docker/Data/log/" 2>/dev/null | head -20
  echo "exit=$?"
  echo ""

  echo "✅ READ-ONLY TIME-BOUNDED PROBE COMPLETE"
} | tee "$OUT"
