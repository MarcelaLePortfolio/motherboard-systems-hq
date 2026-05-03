#!/usr/bin/env bash
set -euo pipefail

setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

TAG="v39.0-value-alignment-foundation-golden"

echo "=== Phase 39: verify main + tag golden ==="
echo "Tag: $TAG"
echo

echo "=== switch to main + pull ==="
git checkout main
git pull --ff-only

echo
echo "=== ensure clean tree ==="
git status --porcelain
test -z "$(git status --porcelain)" || { echo "ERROR: working tree not clean" >&2; git status; exit 2; }

echo
echo "=== run policy test suite ==="
node --test server/policy/__tests__/*.mjs

echo
echo "=== sanity: harnesses (non-fatal) ==="
node scripts/phase39_2_policy_eval_harness.mjs || true
node scripts/phase39_3_grant_harness.mjs || true

echo
echo "=== confirm tag does not already exist ==="
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "ERROR: tag already exists: $TAG" >&2
  git show --no-patch --pretty=oneline "$TAG" || true
  exit 3
fi

echo
echo "=== create + push tag ==="
git tag -a "$TAG" -m "Phase 39: value alignment foundation (policy evaluator + grants + combine; no wiring)"
git push origin "$TAG"

echo
echo "OK: tagged and pushed $TAG"
