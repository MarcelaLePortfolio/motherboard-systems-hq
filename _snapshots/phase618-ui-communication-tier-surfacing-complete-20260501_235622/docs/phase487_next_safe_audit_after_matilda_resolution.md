# Phase 487 — Next Safe Audit After Matilda Resolution

## Classification
SAFE — Read-only, bounded inspection

## Purpose
The latest audit established:

- `launch-matilda.ts` imports `../../../agents/matilda`
- `mirror/agent.ts` is a stub runtime wrapper
- `server.ts` is not the root runtime entrypoint used by the current verification script
- `scripts/server.cjs` is a real server target
- Matilda’s actual resolved module path still needs verification

## Next audit targets
1. The actual Matilda module file contents
2. The root `agent.ts` file that appeared in server search results
3. The likely local dev server target
4. The current runtime verification script assumptions that should later be corrected

## Commands

echo "=== agents/matilda.ts/matilda.mjs (first 120 lines) ==="
sed -n '1,120p' agents/matilda.ts/matilda.mjs || true

echo
echo "=== agents/matilda.ts/askRouter.ts (first 120 lines) ==="
sed -n '1,120p' agents/matilda.ts/askRouter.ts || true

echo
echo "=== root agent.ts (first 120 lines) ==="
sed -n '1,120p' agent.ts || true

echo
echo "=== scripts/_local/dev-server.ts (first 120 lines) ==="
sed -n '1,120p' scripts/_local/dev-server.ts || true

echo
echo "=== current runtime verification script assumptions (server + agent checks only) ==="
grep -nE 'server/index.js|agents/cade.ts|agents/effie.ts|launch-cade|launch-matilda|launch-effie' scripts/_safety/phase487_runtime_verify.sh || true

## Status
READY — Safe and bounded
