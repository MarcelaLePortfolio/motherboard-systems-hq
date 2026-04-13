#!/usr/bin/env bash

set -euo pipefail

PROOFS_DIR="docs/proofs"
OUTPUT_FILE="docs/visibility_latest_run.txt"

LATEST_EXECUTION="$(ls -t ${PROOFS_DIR}/execution_plan_*.json 2>/dev/null | head -n 1 || true)"
LATEST_APPROVAL="$(ls -t ${PROOFS_DIR}/approval_plan_*.json 2>/dev/null | head -n 1 || true)"
LATEST_APPROVAL_FAILURE="$(ls -t ${PROOFS_DIR}/approval_failure_plan_*.json 2>/dev/null | head -n 1 || true)"
LATEST_GOVERNANCE="$(ls -t ${PROOFS_DIR}/governance_plan_*.json 2>/dev/null | head -n 1 || true)"
LATEST_GOVERNANCE_FAILURE="$(ls -t ${PROOFS_DIR}/governance_failure_plan_*.json 2>/dev/null | head -n 1 || true)"
LATEST_INTAKE_FAILURE="$(ls -t ${PROOFS_DIR}/failure_intake_*.json 2>/dev/null | head -n 1 || true)"

{
echo "OPERATOR VISIBILITY — LATEST RUN SNAPSHOT"
echo "========================================="
echo

echo "LATEST GOVERNANCE ARTIFACT"
echo "--------------------------"
[ -n "$LATEST_GOVERNANCE" ] && cat "$LATEST_GOVERNANCE" || echo "NONE"
echo

echo "LATEST GOVERNANCE FAILURE"
echo "-------------------------"
[ -n "$LATEST_GOVERNANCE_FAILURE" ] && cat "$LATEST_GOVERNANCE_FAILURE" || echo "NONE"
echo

echo "LATEST APPROVAL ARTIFACT"
echo "------------------------"
[ -n "$LATEST_APPROVAL" ] && cat "$LATEST_APPROVAL" || echo "NONE"
echo

echo "LATEST APPROVAL FAILURE"
echo "-----------------------"
[ -n "$LATEST_APPROVAL_FAILURE" ] && cat "$LATEST_APPROVAL_FAILURE" || echo "NONE"
echo

echo "LATEST EXECUTION ARTIFACT"
echo "-------------------------"
[ -n "$LATEST_EXECUTION" ] && cat "$LATEST_EXECUTION" || echo "NONE"
echo

echo "LATEST ENTRY FAILURE"
echo "--------------------"
[ -n "$LATEST_INTAKE_FAILURE" ] && cat "$LATEST_INTAKE_FAILURE" || echo "NONE"
echo

} > "$OUTPUT_FILE"

echo "VISIBILITY_OK"
echo "OUTPUT_FILE=${OUTPUT_FILE}"
