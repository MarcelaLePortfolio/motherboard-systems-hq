#!/bin/bash
set -e

echo "PHASE 633 — FULL VALIDATION START"

echo "Step 1: Fresh rebuild"
bash scripts/verify/fresh-db-rebuild.sh

echo "Step 2: Schema assertion"
bash scripts/verify/assert-schema.sh

echo "PHASE 633 — VALIDATION COMPLETE"
echo "If no errors above, schema persistence is confirmed stable."
