#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE80_2_QUEUE_LATENCY_RUNTIME_CHECK_${STAMP}.txt"

{
echo "Phase 80.2 Queue Latency Runtime Verification"
echo "Generated: ${STAMP}"
echo

echo "Checking metric file exists:"
ls public/js/telemetry/queue_latency_metric.js

echo
echo "Checking bootstrap registration:"
grep queue_latency_metric public/js/telemetry/phase65b_metric_bootstrap.js || true

echo
echo "Checking bundle references:"
grep -R "queue_latency_metric" public || true

} > "${OUT}"

echo "Wrote ${OUT}"
