#!/bin/bash
set -e

echo "Running Phase 635 completion sequence..."

echo "Step 1: Validate UI + endpoint"
bash scripts/verify/run-phase635-complete.sh

echo "Step 2: Tag completion"
bash scripts/verify/phase635-mark-complete.sh

echo "PHASE 635 COMPLETE — UI subsystem surfacing fully verified and tagged."
