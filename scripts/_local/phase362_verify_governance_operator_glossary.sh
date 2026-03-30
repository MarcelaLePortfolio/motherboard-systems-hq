#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 362 governance operator glossary verification =="

git status --short

npx vitest run \
tests/governance_operator_glossary/governance_operator_glossary_model.test.ts \
tests/governance_operator_glossary/governance_operator_glossary_formatter.test.ts \
tests/governance_operator_glossary/governance_operator_glossary_builder.test.ts \
tests/governance_operator_glossary/governance_operator_glossary_contract.test.ts

echo "PASS: Phase 362 glossary deterministic."
