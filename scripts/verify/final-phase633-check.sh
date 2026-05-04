#!/bin/bash
set -e

echo "PHASE 633 — FINAL SYSTEM CHECK"

echo "1. Running full DB validation..."
bash scripts/verify/full-phase633-validation.sh

echo "2. Running subsystem validation..."
bash scripts/verify/run-subsystem-validation.sh

echo "PHASE 633 — FINAL CHECK COMPLETE"
echo "System is now:"
echo "- Schema persisted"
echo "- Fresh boot verified"
echo "- Subsystem endpoint wired and testable"
