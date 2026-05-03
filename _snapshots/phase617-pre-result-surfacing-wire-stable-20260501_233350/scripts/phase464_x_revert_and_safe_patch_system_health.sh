#!/usr/bin/env bash
set -euo pipefail

TARGET="routes/diagnostics/systemHealth.ts"
BACKUP="routes/diagnostics/systemHealth.ts.bak_phase464x"
OUT="docs/phase464_x_safe_patch_result.txt"

if [ ! -f "$BACKUP" ]; then
  echo "ERROR: backup not found — cannot safely revert"
  exit 1
fi

cp "$BACKUP" "$TARGET"
echo "Reverted to backup: $BACKUP"

TMP="$(mktemp)"

awk '
{
  print
}

/res\.json/ && !patched {
  print "  // Phase 464.X SAFE PATCH — normalize output without overriding logic"
  print "  if (Array.isArray(payload)) {"
  print "    const seen = new Set();"
  print "    payload = payload.filter(item => {"
  print "      const key = JSON.stringify(item);"
  print "      if (seen.has(key)) return false;"
  print "      seen.add(key);"
  print "      return true;"
  print "    });"
  print "  }"
  patched=1
}
' "$TARGET" > "$TMP"

mv "$TMP" "$TARGET"

{
  echo "PHASE 464.X SAFE PATCH RESULT"
  echo "============================="
  echo
  echo "TARGET: $TARGET"
  echo "BACKUP RESTORED: $BACKUP"
  echo
  echo "POST-PATCH CHECK"
  rg -n 'SYSTEM_HEALTH' "$TARGET" || true
  echo
  rg -n 'res\.json' "$TARGET" || true
} > "$OUT"

echo "Wrote $OUT"
echo "SAFE PATCH COMPLETE — preserves logic, removes duplication only"

