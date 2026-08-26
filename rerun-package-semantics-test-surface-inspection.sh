#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RERUN PACKAGE SEMANTICS TEST SURFACE INSPECTION ==="
echo "EXPECTED_HEAD=69b6e9fe"
echo "AUTHORIZED_BY=ee2d2495"
echo "SCOPE=TEST_DISCOVERY_ONLY"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse --short HEAD)"
if [[ "${CURRENT_HEAD}" != "69b6e9fe" ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== TEST FILE CANDIDATES ==="
find . \
  -type f \
  \( -name '*.test.ts' -o -name '*.spec.ts' -o -name '*.test.js' -o -name '*.spec.js' \) \
  | sort \
  | grep -E 'ollama|interpretation|draft|living|matilda|workflow' \
  | head -80 || true

echo
echo "=== OLLAMA TEST REFERENCES ==="
rg -n \
  'ollamaChat|investigationLifecycle|durableInterpretation|supportSourceReferences' \
  --glob '*.{test,spec}.{ts,js}' \
  . \
  | head -120 || true

echo
echo "=== IEL TEST REFERENCES ==="
rg -n \
  'createInterpretationEvidenceLedgerEntry|listInterpretationEvidenceLedgerEntries|investigation_lifecycle_json|matilda_interpretation_evidence_ledger' \
  --glob '*.{test,spec}.{ts,js}' \
  . \
  | head -120 || true

echo
echo "=== DRAFT SYNTHESIS TEST REFERENCES ==="
rg -n \
  'synthesizeLivingDraft|upsertLivingDraftPackage|proposed_work|expected_outcome|unresolved_questions' \
  --glob '*.{test,spec}.{ts,js}' \
  . \
  | head -120 || true

echo
echo "=== PACKAGE TEST SCRIPTS ==="
node -e '
const p=require("./package.json");
console.log(JSON.stringify(p.scripts ?? {}, null, 2));
'

echo
echo "TEST_SURFACE_DISCOVERY_COMPLETE=YES"
echo "NEXT_ACTION=ADD_ONLY_FOCUSED_TESTS_MATCHING_THE_IDENTIFIED_EXISTING_SURFACES"
