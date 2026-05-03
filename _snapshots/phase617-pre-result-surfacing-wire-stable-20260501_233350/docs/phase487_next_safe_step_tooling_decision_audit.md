# Phase 487 — Next Safe Step: Tooling Decision Audit

## Classification
SAFE — Read-only, bounded inspection

## Purpose
We are down to two likely cleanup items:

1. fix the verification script so it checks the real paths
2. decide the safest way to handle the TypeScript version mismatch

Before changing either one, we inspect:
- recent history for `package.json` / `tsconfig.json`
- whether this repo has ever explicitly set a TypeScript version
- whether `ignoreDeprecations` is already present

## Commands

echo "=== recent history for package.json and tsconfig.json (top 20) ==="
git log --oneline -- package.json tsconfig.json | head -20

echo
echo "=== current TypeScript references ==="
grep -RIn "typescript\|ignoreDeprecations\|moduleResolution" package.json pnpm-lock.yaml tsconfig.json || true

echo
echo "=== current runtime verification script path assumptions ==="
sed -n '1,120p' scripts/_safety/phase487_runtime_verify.sh

## Status
READY — Safe and bounded
