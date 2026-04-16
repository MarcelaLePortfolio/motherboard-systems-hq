#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_force_browser_cache_bust_and_verify_${STAMP}.txt"

# Inject cache-busting meta + version stamp into dashboard.html
TARGET="public/dashboard.html"

if [ ! -f "${TARGET}" ]; then
  echo "Missing ${TARGET}"
  exit 1
fi

cp "${TARGET}" "/tmp/dashboard_cache_bust_${STAMP}.bak"

# Add cache-busting meta tags if not present
if ! grep -q "phase487-cache-bust" "${TARGET}"; then
  awk -v stamp="${STAMP}" '
    BEGIN { inserted=0 }
    /<head>/ && !inserted {
      print
      print "  <!-- phase487-cache-bust -->"
      print "  <meta http-equiv=\"Cache-Control\" content=\"no-cache, no-store, must-revalidate\" />"
      print "  <meta http-equiv=\"Pragma\" content=\"no-cache\" />"
      print "  <meta http-equiv=\"Expires\" content=\"0\" />"
      print "  <meta name=\"phase487-version\" content=\"" stamp "\" />"
      inserted=1
      next
    }
    { print }
  ' "${TARGET}" > "/tmp/dashboard_cache_bust_${STAMP}.tmp"
  mv "/tmp/dashboard_cache_bust_${STAMP}.tmp" "${TARGET}"
fi

# Restart container to ensure fresh serve
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  docker compose restart 2>&1 || docker-compose restart 2>&1 || true
fi

sleep 2

SNAP="docs/phase487_cache_bust_verify_${STAMP}.html"
curl -s http://localhost:8080 > "${SNAP}"

{
  echo "PHASE 487 — FORCE BROWSER CACHE BUST + VERIFY"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== CACHE BUST META CHECK ==="
  grep -n "phase487-cache-bust" "${TARGET}" || true
  grep -n "phase487-version" "${TARGET}" || true
  echo

  echo "=== SERVED BODY CHECK ==="
  grep -n -C 3 "Confidence: limited\|Confidence: insufficient" "${SNAP}" || true
  echo

  echo "=== VERDICT ==="
  if grep -q "Confidence: limited" "${SNAP}"; then
    echo "served_body_contains_confidence_limited=YES"
  else
    echo "served_body_contains_confidence_limited=NO"
  fi

  if grep -q "Confidence: insufficient" "${SNAP}"; then
    echo "served_body_contains_confidence_insufficient=YES"
  else
    echo "served_body_contains_confidence_insufficient=NO"
  fi
  echo
} > "${OUT}"

echo "${OUT}"
echo "${SNAP}"
