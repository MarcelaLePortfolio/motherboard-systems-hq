#!/usr/bin/env bash
set -uo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RUN EVIDENCE COMPOSITION CLOSURE CHECK ==="
echo

./scripts/validate-evidence-composition-corridor-closure.sh
rc=$?

echo
echo "CLOSURE_EXIT_CODE=$rc"

if [[ $rc -ne 0 ]]; then
  echo "EVIDENCE_COMPOSITION_CLOSURE_NOT_RECORDED"
  exit "$rc"
fi

echo "EVIDENCE_COMPOSITION_CLOSURE_VALIDATED"
