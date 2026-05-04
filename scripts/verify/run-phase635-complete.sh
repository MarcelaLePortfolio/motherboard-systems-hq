#!/bin/bash
set -e

echo "Running Phase 635 completion sequence..."

echo "Step 1: Validate endpoint"
bash scripts/verify/test-subsystem-endpoint.sh

echo "Step 2: Open UI for manual validation"
bash scripts/verify/test-subsystem-ui.sh

echo "Step 3: Tag completion"
bash scripts/verify/phase635-mark-complete.sh

echo "PHASE 635 COMPLETE — UI subsystem surfacing fully verified and tagged."
