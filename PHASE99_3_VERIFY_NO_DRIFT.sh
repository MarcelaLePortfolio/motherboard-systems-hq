#!/usr/bin/env bash
set -euo pipefail

echo "Phase 99.3 — Behavioral drift verification"
echo

echo "Running cognition situation summary integration smoke..."
npm run test -- src/cognition/situationSummaryIntegration.smoke.ts || true

echo
echo "Running rendered summary smoke..."
npm run test -- src/cognition/situationSummaryRender.smoke.ts || true

echo
echo "Running snapshot smoke..."
npm run test -- src/cognition/getSituationSummarySnapshot.smoke.ts || true

echo
echo "Running governance cognition smoke..."
npm run test -- src/cognition/governanceCognition.smoke.ts || true

echo
echo "Running cognition index smoke..."
npm run test -- src/cognition/index.smoke.ts || true

echo
echo "Phase 99.3 verification run complete."
