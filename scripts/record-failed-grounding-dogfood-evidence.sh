#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
CAPTURE="/tmp/motherboard-grounding-dogfood-result.log"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

echo "DOGFOOD_RESULT=503_SERVICE_UNAVAILABLE"
echo "DOGFOOD_RETRY_AUTHORIZED=NO"
echo "IMPLEMENTATION_CHANGE_JUSTIFIED=NOT_YET"
echo "NEXT_ACTION=CLASSIFY_CAPTURED_RUNTIME_FAILURE"

echo
echo "=== CAPTURED DOGFOOD LOG ==="
test -f "$CAPTURE"
cat "$CAPTURE"

echo
echo "=== FAILURE SIGNALS ==="
grep -E \
  'Ollama expectedOutcome fidelity diagnostic|Package Semantics fidelity|Conversational response failed|503|Error:' \
  "$CAPTURE" || true

echo
echo "NO_RETRY_PERFORMED=YES"
echo "NEXT_ACTION=PASTE_THIS_OUTPUT_FOR_FAILURE_CLASSIFICATION"
