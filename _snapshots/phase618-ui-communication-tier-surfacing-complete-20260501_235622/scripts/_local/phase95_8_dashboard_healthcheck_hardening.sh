#!/usr/bin/env bash
set -euo pipefail

echo "Phase 95.8 — dashboard health determinism hardening"

TARGET="Dockerfile.dashboard"

if ! grep -q HEALTHCHECK "$TARGET"; then
  echo "Adding container healthcheck"

  awk '
  /EXPOSE 3000/ {
    print
    print ""
    print "HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \\"
    print "  CMD curl -fsS http://127.0.0.1:3000/api/health >/dev/null || exit 1"
    next
  }
  {print}
  ' "$TARGET" > "$TARGET.tmp"

  mv "$TARGET.tmp" "$TARGET"

else
  echo "Healthcheck already present"
fi

echo "Rebuilding dashboard container"
docker compose build dashboard

echo "Restarting dashboard"
docker compose up -d dashboard

echo "Verifying container health"
docker inspect \
$(docker compose ps -q dashboard) \
--format '{{.State.Health.Status}}' || true

echo "Phase 95.8 complete"
