#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/recovery_full_audit/29_candidate_source_verification.txt"

{
echo "PHASE 457 — CANDIDATE SOURCE VERIFICATION"
echo "========================================="
echo

echo "--- phase65_layout package.json ---"
cat ../mbhq_recovery_visual_compare/phase65_layout/package.json 2>/dev/null || echo "missing"
echo

echo "--- phase65_wiring package.json ---"
cat ../mbhq_recovery_visual_compare/phase65_wiring/package.json 2>/dev/null || echo "missing"
echo

echo "--- operator_guidance package.json ---"
cat ../mbhq_recovery_visual_compare/operator_guidance/package.json 2>/dev/null || echo "missing"
echo

echo "--- phase65_layout server entry ---"
ls ../mbhq_recovery_visual_compare/phase65_layout 2>/dev/null || true
echo

echo "--- phase65_wiring server entry ---"
ls ../mbhq_recovery_visual_compare/phase65_wiring 2>/dev/null || true
echo

echo "--- operator_guidance server entry ---"
ls ../mbhq_recovery_visual_compare/operator_guidance 2>/dev/null || true
echo

echo "--- detect identical builds ---"
diff -rq ../mbhq_recovery_visual_compare/phase65_layout ../mbhq_recovery_visual_compare/phase65_wiring || true
echo
diff -rq ../mbhq_recovery_visual_compare/phase65_layout ../mbhq_recovery_visual_compare/operator_guidance || true
echo

echo "DONE"

} > "$OUT"

echo "Wrote:"
echo "$OUT"

