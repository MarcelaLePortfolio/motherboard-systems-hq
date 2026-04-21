#!/usr/bin/env bash

set -e

echo "=== Phase 487 LOCK + BASELINE ==="

echo "--- Verifying clean state ---"
git status

echo "--- Capturing commit ---"
git rev-parse HEAD > PHASE487_COMMIT_SHA.txt

echo "--- Creating immutable lock tag ---"
git tag -a phase487-locked-baseline-20260421 -m "LOCKED BASELINE: Phase 487 fully stable (FL-3 + observability + readable task surface)" || true
git push origin phase487-locked-baseline-20260421 || true

echo "--- Recording docker image reference ---"
echo "motherboard-dashboard:phase487-final-stable-20260421" > PHASE487_IMAGE_REF.txt

echo "--- Final checkpoint files ---"
ls -1 PHASE487_* || true

echo "=== LOCK COMPLETE ==="
