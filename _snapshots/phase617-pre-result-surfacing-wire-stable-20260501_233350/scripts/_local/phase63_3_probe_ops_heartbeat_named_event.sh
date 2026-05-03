#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RAW="docs/checkpoints/PHASE63_3_OPS_HEARTBEAT_NAMED_EVENT_PROBE_20260312.txt"
MD="docs/checkpoints/PHASE63_3_OPS_HEARTBEAT_NAMED_EVENT_FINDINGS_20260312.md"

mkdir -p docs/checkpoints

{
  echo "PHASE 63.3 OPS HEARTBEAT NAMED EVENT PROBE"
  echo "Date: 2026-03-12"
  echo

  echo "== bounded consumer dependency audit =="
  grep -RIn --exclude='*.map' --exclude='*.log' --exclude='*.txt' --exclude='*.bak*' \
    'ops\.heartbeat|addEventListener\("ops\.heartbeat"|lastHeartbeatAt|mb:ops:update|event: heartbeat' \
    public/js server scripts 2>/dev/null || true
  echo

  echo "== live SSE capture =="
} > "$RAW"

curl -Ns http://127.0.0.1:8080/events/ops >> "$RAW" 2>&1 &
SSE_PID=$!

cleanup() {
  kill "$SSE_PID" >/dev/null 2>&1 || true
  wait "$SSE_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

sleep 1

POST_RESPONSE="$(
  curl -sS \
    -X POST \
    -H 'Content-Type: application/json' \
    -d '{"source":"phase63_3_probe","meta":{"reason":"named-event-audit"}}' \
    http://127.0.0.1:8080/api/ops/heartbeat
)"

sleep 3
cleanup
trap - EXIT

{
  echo
  echo "== heartbeat POST response =="
  printf '%s\n' "$POST_RESPONSE"
  echo
  echo "== first 40 SSE lines =="
  sed -n '1,40p' "$RAW"
} >> "$RAW"

HAS_NAMED="no"
if grep -q '^event: ops\.heartbeat$' "$RAW"; then
  HAS_NAMED="yes"
fi

GENERIC_HEARTBEAT_COUNT="$(grep -c '^event: heartbeat$' "$RAW" || true)"
OPS_STATE_COUNT="$(grep -c '^event: ops\.state$' "$RAW" || true)"

cat > "$MD" <<MDOC
# PHASE 63.3 OPS HEARTBEAT NAMED EVENT FINDINGS
Date: 2026-03-12

## Summary

A narrow end-to-end probe was run from the verified Phase 63.2 golden baseline to confirm whether application heartbeat signaling reaches SSE clients as a named event.

## Probe Inputs

- live SSE subscription to \`/events/ops\`
- bounded POST to \`/api/ops/heartbeat\`
- bounded consumer dependency grep

## Results

- named \`ops.heartbeat\` observed: **$HAS_NAMED**
- \`ops.state\` frames observed: **$OPS_STATE_COUNT**
- transport \`heartbeat\` frames observed: **$GENERIC_HEARTBEAT_COUNT**

## Raw Capture

- \`$RAW\`

## Interpretation

If named \`ops.heartbeat\` is **yes**, the application heartbeat corridor is preserved and distinct from transport keepalive heartbeat.

If named \`ops.heartbeat\` is **no**, the audit should treat broadcast argument ordering or write normalization as the next defect candidate.

## Safety

No layout mutation.
No ID changes.
No structural wrappers.
Audit only.
MDOC

scripts/verify-phase63-telemetry-baseline.sh
git status --short --branch
git --no-pager log --oneline --decorate -n 8

echo
echo "wrote $RAW"
echo "wrote $MD"
