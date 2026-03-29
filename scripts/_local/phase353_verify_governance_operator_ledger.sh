#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 353 governance operator ledger verification =="

echo
git status --short

echo
echo "-- running ledger tests --"

npx vitest run \
tests/governance_operator_ledger/governance_operator_ledger_model.test.ts \
tests/governance_operator_ledger/governance_operator_ledger_formatter.test.ts \
tests/governance_operator_ledger/governance_operator_ledger_builder.test.ts \
tests/governance_operator_ledger/governance_operator_ledger_contract.test.ts

echo
echo "PASS: governance operator ledger deterministic."
