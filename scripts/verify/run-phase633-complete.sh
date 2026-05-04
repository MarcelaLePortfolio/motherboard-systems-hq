#!/bin/bash
set -e

echo "Running full Phase 633 completion sequence..."

echo "Step 1: Execute final validation"
bash scripts/verify/run-phase633-final.sh

echo "Step 2: Tag completion"
bash scripts/verify/phase633-mark-complete.sh

echo "PHASE 633 COMPLETE — system hardened and verified."
