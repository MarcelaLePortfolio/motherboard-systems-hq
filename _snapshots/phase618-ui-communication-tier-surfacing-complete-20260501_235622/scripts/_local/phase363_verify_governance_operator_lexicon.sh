#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 363 governance operator lexicon verification =="

git status --short

npx vitest run \
tests/governance_operator_lexicon/governance_operator_lexicon_model.test.ts \
tests/governance_operator_lexicon/governance_operator_lexicon_formatter.test.ts \
tests/governance_operator_lexicon/governance_operator_lexicon_builder.test.ts \
tests/governance_operator_lexicon/governance_operator_lexicon_contract.test.ts

echo "PASS: Phase 363 lexicon deterministic."
