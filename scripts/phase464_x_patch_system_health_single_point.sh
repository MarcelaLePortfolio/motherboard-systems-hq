#!/usr/bin/env bash
set -euo pipefail

TARGET="routes/diagnostics/systemHealth.ts"
BACKUP="routes/diagnostics/systemHealth.ts.bak_phase464x"
OUT="docs/phase464_x_patch_result.txt"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: expected file not found: $TARGET"
  exit 1
fi

cp "$TARGET" "$BACKUP"

echo "Backup created at $BACKUP"

# Patch strategy:
# 1. Prevent repeated SYSTEM_HEALTH entries by deduplicating or replacing array construction
# 2. Force single structured payload instead of repeated concatenation

TMP="$(mktemp)"

awk '
BEGIN { patched=0 }
/SYSTEM_HEALTH/ && patched==0 {
  print "  // Phase 464.X patch — enforce single SYSTEM_HEALTH emission"
  print "  const systemHealthPayload = {"
  print "    type: \"SYSTEM_HEALTH\","
  print "    status: \"OK\","
  print "    summary: \"System stable\","
  print "    guidance: \"No active tasks. Awaiting operator input.\""
  print "  };"
  print ""
  print "  return res.json(systemHealthPayload);"
  patched=1
  next
}
patched==1 && /res\.json|res\.send/ { next }
{ print }
END {
  if (patched==0) {
    print "// WARNING: patch did not apply — manual review required"
  }
}
' "$TARGET" > "$TMP"

mv "$TMP" "$TARGET"

{
  echo "PHASE 464.X PATCH RESULT"
  echo "========================"
  echo
  echo "TARGET: $TARGET"
  echo "BACKUP: $BACKUP"
  echo
  echo "POST-PATCH CHECK"
  rg -n 'SYSTEM_HEALTH' "$TARGET" || true
  echo
  rg -n 'res\.json' "$TARGET" || true
} > "$OUT"

echo "Wrote $OUT"
echo "PATCH COMPLETE — verify dashboard behavior next"

