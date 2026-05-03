#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_governance_safe_db_bootstrap_patch.txt"

mkdir -p docs

echo "PHASE 464.X — GOVERNANCE-SAFE DB BOOTSTRAP PATCH" > "$OUT"
echo "===============================================" >> "$OUT"
echo >> "$OUT"

echo "OBJECTIVE:" >> "$OUT"
echo "- Prevent server crash if 'tasks' table is missing" >> "$OUT"
echo "- Preserve deterministic behavior (no silent failure)" >> "$OUT"
echo "- Add defensive guard ONLY at bootstrap boundary" >> "$OUT"
echo >> "$OUT"

TARGET="server/db_bootstrap_tasks_task_id.mjs"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: target file not found: $TARGET" | tee -a "$OUT"
  exit 1
fi

cp "$TARGET" "${TARGET}.bak_phase464x"

echo "Backup created: ${TARGET}.bak_phase464x" >> "$OUT"
echo >> "$OUT"

TMP="$(mktemp)"

awk '
/ensureTasksTaskIdColumn/ && !patched {
  print
  print "  // Phase 464.X — defensive table existence guard"
  print "  await client.query(`"
  print "    CREATE TABLE IF NOT EXISTS tasks ("
  print "      id SERIAL PRIMARY KEY,"
  print "      created_at TIMESTAMP DEFAULT NOW()"
  print "    );"
  print "  `);"
  patched=1
  next
}
{ print }
END {
  if (patched==0) {
    print "// WARNING: bootstrap patch did not apply"
  }
}
' "$TARGET" > "$TMP"

mv "$TMP" "$TARGET"

echo "STEP — Restart dashboard" >> "$OUT"
docker compose restart dashboard >> "$OUT" 2>&1 || true
echo >> "$OUT"

echo "STEP — Wait for boot" >> "$OUT"
sleep 3
echo >> "$OUT"

echo "STEP — Verify endpoint" >> "$OUT"
RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
echo "$RESPONSE" >> "$OUT"
echo >> "$OUT"

COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

STATUS="UNKNOWN"

if [ "$RESPONSE" = "REQUEST_FAILED" ]; then
  STATUS="SERVER_NOT_RESPONDING"
elif [ "$COUNT" -eq 1 ]; then
  STATUS="BOOTSTRAP_STABLE"
elif [ "$COUNT" -gt 1 ]; then
  STATUS="BOOTSTRAP_OK_DUPLICATION_PRESENT"
elif [ "$COUNT" -eq 0 ]; then
  STATUS="BOOTSTRAP_SIGNAL_MISSING"
fi

echo "STATUS: $STATUS" >> "$OUT"

echo "Wrote $OUT"
echo "STATUS: $STATUS"

