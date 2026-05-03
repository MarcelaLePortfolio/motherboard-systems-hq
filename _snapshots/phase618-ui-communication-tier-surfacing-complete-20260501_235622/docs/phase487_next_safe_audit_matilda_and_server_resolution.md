# Phase 487 — Next Safe Audit: Matilda and Server Resolution

## Classification
SAFE — Read-only, bounded inspection

## Purpose
The latest audit established:

- `routes/diagnostics/systemHealth.ts` is now structurally clean
- `scripts/utils/log.js` exists for Effie
- the current runtime verification script still contains an incorrect server-path assumption (`server/index.js`)

Before changing any verification logic, we will inspect:

1. the actual Matilda launcher import target
2. the actual root/mirror agent runtime wrapper
3. the likely real server start path(s)

## Commands

echo "=== launch-matilda.ts (first 80 lines) ==="
sed -n '1,80p' scripts/_local/agent-runtime/launch-matilda.ts

echo
echo "=== mirror/agent.ts (first 120 lines) ==="
sed -n '1,120p' mirror/agent.ts

echo
echo "=== root index.ts (first 120 lines) ==="
sed -n '1,120p' index.ts || true

echo
echo "=== search for app.listen / createServer (top 40) ==="
grep -RInE 'app\.listen|createServer\(' . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  | head -40 || true

## Status
READY — Safe and bounded
