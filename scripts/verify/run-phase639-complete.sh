#!/bin/bash
set -e

echo "PHASE 639 — COMPLETION SEQUENCE START"

echo "Step 1: Validate guidance + subsystem integration"
bash scripts/verify/test-guidance-subsystem.sh

echo "Step 2: Tag completion"
git tag -a phase639-complete -m "Phase 639 complete: guidance enriched with subsystem state (read-only)"
git push origin phase639-complete

echo "PHASE 639 COMPLETE — guidance-subsystem integration verified and tagged."
