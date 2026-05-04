#!/bin/bash
set -e

echo "Running Phase 634 completion sequence..."

echo "Step 1: Validate Atlas subsystem"
bash scripts/verify/run-phase634-validation.sh

echo "Step 2: Tag completion"
bash scripts/verify/phase634-mark-complete.sh

echo "PHASE 634 COMPLETE — Atlas subsystem surfaced and verified."
