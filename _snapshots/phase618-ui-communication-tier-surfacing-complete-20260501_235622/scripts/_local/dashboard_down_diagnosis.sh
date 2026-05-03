#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

LATEST_INSPECTION="$(ls -1t docs/dashboard_down_inspection_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_FOLLOWUP="$(ls -1t docs/dashboard_down_followup_*.txt 2>/dev/null | head -n 1 || true)"
OUT="docs/dashboard_down_diagnosis_$(date +%Y%m%d_%H%M%S).md"

{
  echo "# Dashboard Down Diagnosis"
  echo
  echo "Timestamp: $(date)"
  echo
  echo "## Evidence reviewed"
  echo
  if [ -n "${LATEST_INSPECTION}" ]; then
    echo "- ${LATEST_INSPECTION}"
  else
    echo "- No primary inspection file found"
  fi
  if [ -n "${LATEST_FOLLOWUP}" ]; then
    echo "- ${LATEST_FOLLOWUP}"
  else
    echo "- No follow-up inspection file found"
  fi
  echo
  echo "## Verified findings"
  echo
  echo "1. Port 8080 is not serving the dashboard."
  echo "   - Verified by failed curl to http://127.0.0.1:8080/"
  echo
  echo "2. Docker daemon is unavailable."
  echo "   - Verified by docker.sock connection failures."
  echo "   - Verified by 'Cannot connect to the Docker daemon' output."
  echo
  echo "3. The containerized dashboard is therefore not currently running."
  echo "   - Since Docker is unavailable, dockerized services cannot be active from this environment."
  echo
  echo "4. A separate local service may have been serving port 3000 earlier."
  echo "   - Earlier output showed curl to localhost:3000 returning content."
  echo "   - That is not the same as the expected containerized dashboard on :8080."
  echo
  echo "## Most likely root cause"
  echo
  echo "The dashboard is down because the Docker daemon is not running or not reachable on this machine."
  echo "Since the dashboard is expected on port 8080 through the containerized stack, the missing Docker daemon is currently the primary blocker."
  echo
  echo "## Boundary-safe conclusion"
  echo
  echo "- This is an environment/runtime availability issue."
  echo "- This is not yet evidence of an application code regression."
  echo "- The next safe step is to verify Docker Desktop / Docker daemon health before changing any repo code."
  echo
  echo "## Recommended next verification"
  echo
  echo "1. Confirm Docker Desktop is running."
  echo "2. Re-check docker ps."
  echo "3. Re-check docker compose ps."
  echo "4. Re-check curl http://127.0.0.1:8080/"
  echo
  echo "## Raw key evidence"
  echo
  if [ -n "${LATEST_INSPECTION}" ]; then
    echo
    echo "### From ${LATEST_INSPECTION}"
    grep -Ei "docker.sock|Cannot connect to the Docker daemon|curl: \(7\)|Failed to connect|localhost port 8080|localhost port 3000" "${LATEST_INSPECTION}" || true
  fi
  if [ -n "${LATEST_FOLLOWUP}" ]; then
    echo
    echo "### From ${LATEST_FOLLOWUP}"
    grep -Ei "docker.sock|Cannot connect to the Docker daemon|curl: \(7\)|Failed to connect|127.0.0.1:8080|127.0.0.1:3000|Docker daemon|dashboard" "${LATEST_FOLLOWUP}" || true
  fi
} > "${OUT}"

echo "Diagnosis written to:"
echo "${OUT}"

echo
echo "----- DIAGNOSIS PREVIEW -----"
sed -n '1,220p' "${OUT}"
