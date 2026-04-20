# Phase 487 — Safe Audit: Agent Targets and tsconfig Implications

## Classification
SAFE — Read-only, bounded inspection

## What the last audit established

### Actual server targets
- `server.ts` is a real server entrypoint
- `scripts/server.cjs` is also a real server target
- the earlier `server/index.js` check was based on the wrong assumption

### Current package/tooling state
- `express` and `pg` are present
- `typescript` is now installed
- `tsconfig.json` includes only:
  - `./scripts`
  - `./routes`
  - `./db`
  - `./types`

### Important implication
The current `tsc --noEmit` result is not proving whole-repo runtime correctness.
It is only proving correctness inside the current `tsconfig` include scope.

## Next audit purpose
Confirm whether:
1. missing `agents/cade.ts` and `agents/effie.ts` actually matter
2. current runtime targets import those files at all
3. TypeScript 6 deprecation is purely tooling-level and not a runtime break

## Commands

echo "=== Search for imports/usages of agents/cade and agents/effie (top 40) ==="
grep -RInE 'agents/cade|agents/effie|from "./agents/cade|from "./agents/effie|from "../agents/cade|from "../agents/effie' . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  | head -40 || true

echo
echo "=== List actual agents tree (top 60) ==="
find agents -maxdepth 3 -type f | sort | head -60 || true

echo
echo "=== Inspect current launcher imports ==="
sed -n '1,80p' scripts/_local/agent-runtime/launch-cade.ts
echo
sed -n '1,80p' scripts/_local/agent-runtime/launch-matilda.ts
echo
sed -n '1,80p' scripts/_local/agent-runtime/launch-effie.ts

## Status
READY — Safe and bounded
