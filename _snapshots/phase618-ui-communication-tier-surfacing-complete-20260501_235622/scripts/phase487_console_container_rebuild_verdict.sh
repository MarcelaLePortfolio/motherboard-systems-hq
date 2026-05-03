#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_inspect_and_rebuild_actual_8080_container_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No container rebuild inspection doc found."
  exit 1
fi

OUT="docs/phase487_console_container_rebuild_verdict_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "PHASE 487 — CONTAINER REBUILD VERDICT"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== HOST ARTIFACT CHECK ==="
  awk '/=== HOST ARTIFACT CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== CONTAINER /app/public/dashboard.html CHECK ==="
  awk '/=== CONTAINER \/app\/public\/dashboard.html CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== POST-REBUILD CONTAINER /app/public/dashboard.html CHECK ==="
  awk '/=== POST-REBUILD CONTAINER \/app\/public\/dashboard.html CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== SERVED BODY CHECK ==="
  awk '/=== SERVED BODY CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== VERDICT ==="
  if awk '/=== SERVED BODY CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | grep -q "Confidence: insufficient"; then
    echo "served_body_contains_confidence_insufficient=YES"
  else
    echo "served_body_contains_confidence_insufficient=NO"
  fi

  if awk '/=== POST-REBUILD CONTAINER \/app\/public\/dashboard.html CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | grep -q "Confidence: insufficient"; then
    echo "container_public_dashboard_contains_confidence_insufficient=YES"
  else
    echo "container_public_dashboard_contains_confidence_insufficient=NO"
  fi

  if awk '/=== HOST ARTIFACT CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | grep -q "Confidence: insufficient"; then
    echo "host_public_dashboard_contains_confidence_insufficient=YES"
  else
    echo "host_public_dashboard_contains_confidence_insufficient=NO"
  fi
  echo

  echo "=== NEXT ACTION ==="
  echo "If served_body_contains_confidence_insufficient=YES while both host and container public dashboard checks are NO,"
  echo "the string is being rendered client-side from bundled JS/runtime code after HTML load."
  echo "Next patch target is the active dashboard JS bundle or bundle entrypoint actually serving 8080."
  echo
} | tee "${OUT}"
