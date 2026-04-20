# Phase 487 — Agent Path Resolution Findings

## Classification
SAFE — Audit-only documentation

## What the latest audit proved

### 1. The earlier `agents/cade.ts` / `agents/effie.ts` concern was based on the wrong path assumption
The current launcher files import:

- `../../agents/cade`
- `../../agents/effie`

from:

- `scripts/_local/agent-runtime/launch-cade.ts`
- `scripts/_local/agent-runtime/launch-effie.ts`

That resolves to:

- `scripts/agents/cade.ts`
- `scripts/agents/effie.ts`

NOT to:

- `agents/cade.ts`
- `agents/effie.ts`

### 2. Therefore the prior audit check for:
- `agents/cade.ts`
- `agents/effie.ts`

was not the correct runtime relevance check.

### 3. Actual server targets
Audit also showed real entrypoint candidates include:

- `server.ts`
- `scripts/server.cjs`

So the earlier `server/index.js` check was also based on the wrong assumption.

### 4. Typecheck scope
Current `tsconfig.json` includes:

- `./scripts`
- `./routes`
- `./db`
- `./types`

So current `tsc --noEmit` is checking a bounded subset of the repo, not every file in the project.

## Safe conclusion

The current remaining unknowns are now narrower:

1. Do `scripts/agents/cade.ts` and `scripts/agents/effie.ts` exist and look intact?
2. Should the runtime verification script be corrected to check:
   - `scripts/agents/cade.ts`
   - `scripts/agents/effie.ts`
   - `server.ts` / `scripts/server.cjs`
   instead of the earlier assumed paths?
3. Is the TypeScript 6 deprecation warning best handled by:
   - pinning TS 5.x
   - or adding the supported deprecation-silencing field in `tsconfig.json`

## Next step
Do a final SAFE read-only audit of:
- `scripts/agents/cade.ts`
- `scripts/agents/effie.ts`
- current launcher resolution assumptions

No mutation yet.
