#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Inspect Metric Targets"
echo

echo "Protected dashboard metric anchors:"
grep -nE 'data-metric=|id=|class=' public/dashboard.html | grep -E 'metric|tile|stat|tasks|running|agent|event' || true
echo

echo "Bundle references touching metrics/telemetry:"
grep -RInE 'data-metric|running-tasks|task-events|metric|telemetry' public/js || true
echo

echo "Inspection complete."
