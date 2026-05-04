#!/bin/bash
set -e

echo "Executing Phase 633 final validation..."

bash scripts/verify/final-phase633-check.sh

echo "Done. If all steps passed without errors, Phase 633 is complete and stable."
