#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
SOURCE="public/dashboard_recomposed_from_stable_quarters_probe.html"
BACKUP="public/dashboard.html.phase476_6_pre_strip.bak"
OUT="docs/phase476_6_strip_dashboard_to_recomposed_shape.txt"

mkdir -p docs

cp "$TARGET" "$BACKUP"

cp "$SOURCE" "$TARGET"

cat > "$OUT" <<EOT
PHASE 476.6 — STRIP DASHBOARD TO RECOMPOSED SHAPE
================================================

ACTION
- dashboard.html replaced with recomposed stable probe structure

SOURCE
- $SOURCE

BACKUP
- $BACKUP

INTENT
- Force dashboard route to use known-stable recomposed structure
- Eliminate any hidden corruption from original composition

NEXT STEP
- Rebuild and observe dashboard route directly
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

docker compose build dashboard
docker compose up -d dashboard

READY=0
for i in {1..20}; do
  if curl -s --max-time 2 http://localhost:8080/dashboard.html >/dev/null 2>&1; then
    READY=1
    echo "READY_ON_8080 attempt=$i"
    break
  fi
  sleep 1
done

echo
echo "STEP — Probe dashboard route"
curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
echo

echo "DECISION TARGET"
echo "- Open http://localhost:8080/dashboard.html"
echo "- Report EXACTLY one of:"
echo "  • DASHBOARD_NOW_STABLE"
echo "  • DASHBOARD_STILL_UNRESPONSIVE"
echo "  • WHITE_SCREEN_RETURNED"
