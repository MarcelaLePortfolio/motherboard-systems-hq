#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_identify_actual_8080_server_artifact_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No 8080 server artifact identification doc found."
  exit 1
fi

OUT="docs/phase487_console_8080_server_verdict_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "PHASE 487 — CONSOLE 8080 SERVER VERDICT"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SERVED VS PUBLIC VERDICT SNAPSHOT ==="
  awk '/=== SERVED VS PUBLIC VERDICT SNAPSHOT ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== PORT 8080 OWNER ==="
  awk '/=== PORT 8080 OWNER ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== PROCESS DETAILS ==="
  awk '/=== PROCESS DETAILS ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== FULL COMMAND LINE ==="
  awk '/=== FULL COMMAND LINE ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== EXPRESS / STATIC / DASHBOARD ENTRYPOINT SEARCH (TOP) ==="
  awk '/=== EXPRESS \/ STATIC \/ DASHBOARD ENTRYPOINT SEARCH ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' | head -n 120 || true
  echo

  echo "=== OPERATOR READ ==="
  echo "Use the process command + entrypoint hits above to determine the actual artifact serving port 8080."
  echo "Next patch must target that artifact or restart that exact server."
  echo
} | tee "${OUT}"
