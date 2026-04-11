#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase476_6_pre_strip.bak"
OUT="docs/phase476_8_restore_real_dashboard_attributes_only.txt"

mkdir -p docs

cat > "$OUT" <<EOT
PHASE 476.8 — RESTORE REAL DASHBOARD ATTRIBUTES (NO STRUCTURE CHANGE)
=====================================================================

CRITICAL CONTEXT
- Current dashboard is STABLE
- Stability achieved using recomposed structure (sanitized body)
- This is NOT the true original dashboard yet

OBJECTIVE
- Reintroduce ONLY non-structural attributes from original dashboard:
  • body class
  • wrapper classes
- DO NOT reintroduce:
  • scripts
  • removed sections
  • structural differences

METHOD
- Extract body tag attributes from backup
- Apply them to current stable dashboard

INTENT
- Identify whether styling/attribute layer contributes to freeze
- Maintain structural stability while increasing fidelity

NEXT STEP
- Observe dashboard again after attribute restoration
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

# Extract original body tag line
ORIGINAL_BODY=$(grep -i "<body" "$BACKUP" | head -n 1)

# Replace current body tag with original attributes (safe substitution)
perl -0777 -pe "s|<body[^>]*>|$ORIGINAL_BODY|i" "$TARGET" > "${TARGET}.tmp"
mv "${TARGET}.tmp" "$TARGET"

echo
echo "Applied original body attributes:"
echo "$ORIGINAL_BODY"
echo

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
echo "  • ATTRIBUTES_REINTRO_STABLE"
echo "  • ATTRIBUTES_REINTRO_BREAKS"
echo "  • WHITE_SCREEN_RETURNED"
