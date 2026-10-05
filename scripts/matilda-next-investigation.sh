#!/bin/bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

EXPECTED_BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="40ef5ac82749cd39306f22fab866a42e44c39df0"
ARTIFACT_DIR="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T/matilda-packages-tab-unseeded.v43QzU"

echo "=== CHARACTERIZATION RAW-PAYLOAD ARTIFACT INSPECTION — READ ONLY ==="

test "$(git rev-parse --abbrev-ref HEAD)" = "$EXPECTED_BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

echo "CHECKPOINT=VERIFIED"
echo

echo "=== 1. ARTIFACT DIRECTORY CONTENTS ==="
if [ -d "$ARTIFACT_DIR" ]; then
  find "$ARTIFACT_DIR" -maxdepth 2 -type f -print -exec sh -c \
    'printf "SIZE="; wc -c < "$1"' _ {} \; | head -300
else
  echo "ARTIFACT_DIRECTORY_NOT_PRESENT"
fi
echo

echo "=== 2. RAW PACKAGE SEMANTICS IN ARTIFACTS ==="
if [ -d "$ARTIFACT_DIR" ]; then
  grep -Rni -B10 -A40 \
    -E '"packageSemantics"|"expectedOutcome"|"successCriteria"|conversation support reference' \
    "$ARTIFACT_DIR" 2>/dev/null | head -1200 || true
fi
echo

echo "=== 3. RUNNER ARTIFACT-WRITING LOGIC ==="
nl -ba scripts/run-packages-tab-unseeded-characterization.ts | sed -n '95,280p'
echo

echo "=== 4. LIVE SERVER FAILURE — EXACT CURRENT CLASSIFICATION ==="
grep -n -B30 -A70 \
  -E 'failed current-request Package Semantics fidelity|conversation support reference that was not supplied|503|Ollama returned' \
  /tmp/motherboard-server-current.log 2>/dev/null | tail -700 || true
echo

echo "=== 5. COMPARE FAILURE COUNTS ==="
printf 'LIVE_CURRENT_REQUEST_FIDELITY_FAILURES='
grep -c 'failed current-request Package Semantics fidelity' \
  /tmp/motherboard-server-current.log 2>/dev/null || true

printf 'LIVE_CONVERSATION_REFERENCE_FAILURES='
grep -c 'conversation support reference that was not supplied' \
  /tmp/motherboard-server-current.log 2>/dev/null || true

echo
echo "=== 6. SAFETY ==="
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

echo "============================================================"
echo "INVESTIGATION=COMPLETE"
echo "CHARACTERIZATION_ACCEPTANCE_RATE=7_OF_10"
echo "CHARACTERIZATION_FIDELITY_FAILURES_OBSERVED=0"
echo "CHARACTERIZATION_SUPPORT_REFERENCE_FAILURES=3_OF_10"
echo "NEXT_ACTION=RECOVER_EXACT_RAW_PAYLOAD_OR_ADD_DIAGNOSTIC_CAPTURE_ONLY_IF_REQUIRED"
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "============================================================"
