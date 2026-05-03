#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

assert_file_contains() {
  local file="$1"
  local pattern="$2"
  local message="$3"

  if ! grep -Fq "$pattern" "$file"; then
    echo "FAIL: $message"
    echo "  file: $file"
    echo "  expected pattern: $pattern"
    exit 1
  fi
}

assert_file_exists() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "FAIL: missing file $file"
    exit 1
  fi
}

assert_file_exists "src/cognition/confidence/confidence.types.ts"
assert_file_exists "src/cognition/confidence/confidenceSynthesizer.ts"
assert_file_exists "src/cognition/confidence/confidenceInvariant.ts"
assert_file_exists "src/cognition/situationSummaryComposer.ts"
assert_file_exists "src/cognition/operatorGuidanceConfidence.ts"
assert_file_exists "src/cognition/operatorGuidanceReducer.ts"

assert_file_contains \
  "src/cognition/confidence/confidence.types.ts" \
  'export type OperationalConfidenceLevel =' \
  "operational confidence level contract must exist"

assert_file_contains \
  "src/cognition/confidence/confidence.types.ts" \
  '"LOW"' \
  "LOW confidence level must be defined"

assert_file_contains \
  "src/cognition/confidence/confidence.types.ts" \
  '"MEDIUM"' \
  "MEDIUM confidence level must be defined"

assert_file_contains \
  "src/cognition/confidence/confidence.types.ts" \
  '"HIGH"' \
  "HIGH confidence level must be defined"

assert_file_contains \
  "src/cognition/confidence/confidenceSynthesizer.ts" \
  'export function synthesizeOperationalConfidence(' \
  "operational confidence synthesizer must exist"

assert_file_contains \
  "src/cognition/confidence/confidenceInvariant.ts" \
  'export function verifyOperationalConfidenceDeterminism()' \
  "operational confidence determinism proof must exist"

assert_file_contains \
  "src/cognition/situationSummaryComposer.ts" \
  'operationalConfidence?: OperationalConfidence;' \
  "situation summary must expose operational confidence"

assert_file_contains \
  "src/cognition/situationSummaryComposer.ts" \
  'operationalConfidence: buildSituationOperationalConfidence({' \
  "situation summary must integrate operational confidence"

assert_file_contains \
  "src/cognition/operatorGuidanceConfidence.ts" \
  'export interface OperatorGuidanceConfidenceInput {' \
  "guidance confidence input contract must exist"

assert_file_contains \
  "src/cognition/operatorGuidanceConfidence.ts" \
  'operationalConfidence?: OperationalConfidence;' \
  "guidance confidence input must accept operational confidence"

assert_file_contains \
  "src/cognition/operatorGuidanceConfidence.ts" \
  'export function mapOperationalConfidenceToGuidanceModifier(' \
  "guidance confidence modifier mapping must exist"

assert_file_contains \
  "src/cognition/operatorGuidanceConfidence.ts" \
  'export function confidencePriorityWeight(' \
  "guidance confidence priority weight must exist"

assert_file_contains \
  "src/cognition/operatorGuidanceReducer.ts" \
  'executionAuthority: "none"' \
  "guidance reducer must preserve bounded execution authority"

assert_file_contains \
  "src/cognition/operatorGuidanceReducer.ts" \
  'surfaceConfidence: confidence.confidence,' \
  "guidance reducer must preserve surface confidence output"

echo "phase99 cognition invariants: PASS"
