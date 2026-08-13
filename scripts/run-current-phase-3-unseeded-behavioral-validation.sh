#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN CURRENT PHASE 3 CORRIDOR 2 — UNSEEDED BEHAVIORAL VALIDATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor d8256e8d HEAD
git merge-base --is-ancestor 842e5ec5 HEAD

echo "DR_CHECKPOINT=20260813_102951"
echo "CORRIDOR_1_DR_PROTECTED=YES"
echo "CORRIDOR_2_EXECUTION_READINESS=ESTABLISHED"
echo "PRODUCTION_GENERATION_POLICY=UNCHANGED_UNCONFIGURED_UNSEEDED"
echo "RUNNER=scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh"

./scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh
