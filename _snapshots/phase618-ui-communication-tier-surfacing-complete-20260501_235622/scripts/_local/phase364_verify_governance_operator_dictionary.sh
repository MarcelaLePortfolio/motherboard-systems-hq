#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 364 governance operator dictionary verification =="

git status --short

npx vitest run \
tests/governance_operator_dictionary/governance_operator_dictionary_model.test.ts \
tests/governance_operator_dictionary/governance_operator_dictionary_formatter.test.ts \
tests/governance_operator_dictionary/governance_operator_dictionary_builder.test.ts \
tests/governance_operator_dictionary/governance_operator_dictionary_contract.test.ts

echo "PASS: Phase 364 dictionary deterministic."
