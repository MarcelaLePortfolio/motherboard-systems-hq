# Phase 487 — tsconfig Deprecation Fix

## Classification
DESTRUCTIVE — Minimal single-file config correction

## Why this is the safest next move
The corrected runtime verifier now shows:
- real server targets exist
- real agent targets exist
- real launcher targets exist

The only remaining blocker is a TypeScript 6 tooling/config mismatch:

- `moduleResolution: "node"` now triggers a deprecation warning
- TypeScript explicitly recommends:
  - `"ignoreDeprecations": "6.0"`

## Scope
- One file:
  - `tsconfig.json`

## Reversible
A backup is created first:
- `tsconfig.json.bak_phase487`

## Intended effect
- Silence the TypeScript 6 deprecation warning
- Preserve current project behavior
- Avoid larger dependency rollback

## Follow-up
After patch:
- rerun typecheck
- rerun corrected runtime verification
