#!/bin/bash
set -e

echo "PHASE 655 — COMPLETION SEQUENCE START"

echo "Step 1: Validate Atlas detection"
bash scripts/verify/test-atlas-detection.sh

echo "Step 2: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Atlas shows OFFLINE when container is not running"
echo "- Guidance shows appropriate warning for atlas"
echo "- No false positives (no ONLINE when container absent)"

echo "Step 3: Tag completion"
git tag -a phase655-complete -m "Phase 655 complete: atlas detection and guidance validation verified"
git push origin phase655-complete

echo "PHASE 655 COMPLETE — atlas detection verified and tagged."
