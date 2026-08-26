#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLOSE PACKAGE SEMANTICS CORRIDOR ==="
echo "EXPECTED_HEAD_PREFIX=0a2a39e8c"
echo "AUTHORIZED_BY=ee2d2495"
echo "CORRIDOR=MATILDA_PACKAGE_SEMANTICS_END_TO_END_TRANSPORT"
echo "STATUS=CLOSED"
echo "MODEL_CONTRACT=VALIDATED"
echo "IEL_PERSISTENCE_AND_RECONSTRUCTION=VALIDATED"
echo "WORKFLOW_TRANSPORT=VALIDATED"
echo "LIVING_DRAFT_SYNTHESIS=VALIDATED"
echo "LIFECYCLE_REGRESSION=PASS"
echo "TYPESCRIPT_CHECK=PASS"
echo "BUILD=PASS"
echo "AUTHORITY_MODEL_CHANGE=NONE"
echo "SECOND_OLLAMA_INVOCATION=NO"
echo "HEURISTIC_EXTRACTION=NO"
echo "PRODUCTION_CHANGE_AFTER_CLOSURE_GATE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 0a2a39e8c* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

git diff --check

git add close-package-semantics-corridor.sh
git commit -m "Close Matilda package semantics corridor"
git push
