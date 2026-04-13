#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase462_1_live_proof_anchor_scan.txt"

{
  echo "PHASE 462 - STEP 1"
  echo "LIVE PROOF IMPLEMENTATION ANCHOR SCAN"
  echo "====================================="
  echo
  echo "OBJECTIVE"
  echo "Identify the safest existing code anchors for the first live proof path."
  echo
  echo "SCAN TIME (UTC)"
  date -u +"%Y-%m-%dT%H:%M:%SZ"
  echo

  echo "REPOSITORY ROOT"
  pwd
  echo

  echo "1) OPERATOR / REQUEST / INTAKE SURFACES"
  grep -RInE "OperatorRequest|rawInput|requestId|intakeId|PlanningInput|IntakeEnvelope|intake|operator request" src app server scripts --exclude-dir=node_modules 2>/dev/null || true
  echo

  echo "2) GOVERNANCE SURFACES"
  grep -RInE "governance|Governance|decisionId|APPROVED|approval|authorize|authorization|policy" src app server scripts --exclude-dir=node_modules 2>/dev/null || true
  echo

  echo "3) EXECUTION SURFACES"
  grep -RInE "execution|ExecutionResult|execute|runConsumption|run.*Entrypoint|taskId|approvedTasks|trigger" src app server scripts --exclude-dir=node_modules 2>/dev/null || true
  echo

  echo "4) VALIDATION SURFACES"
  grep -RInE "validate|ValidationResult|INVALID_|valid:" src app server scripts --exclude-dir=node_modules 2>/dev/null || true
  echo

  echo "5) DASHBOARD / API ROUTE SURFACES"
  grep -RInE "route\\.ts|/api/|POST\\(|GET\\(|NextRequest|NextResponse|export async function" app src server --exclude-dir=node_modules 2>/dev/null || true
  echo

  echo "6) PROOF / DOCS / EXISTING TRACE SURFACES"
  grep -RInE "docs/proofs|proof|trace|artifact" docs src app server scripts --exclude-dir=node_modules 2>/dev/null || true
  echo

  echo "7) TOP-LEVEL TYPE / CONTRACT FILE CANDIDATES"
  find src app server -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.mjs" \) 2>/dev/null | sort
  echo

  echo "8) PACKAGE SCRIPTS"
  if [ -f package.json ]; then
    cat package.json
  else
    echo "package.json not found"
  fi
  echo

  echo "9) RECOMMENDED NEXT MUTATION TARGETS"
  echo "Review the grep hits above and select:"
  echo "- one intake entry surface"
  echo "- one governance decision surface"
  echo "- one execution consumer surface"
  echo "- one proof artifact write surface"
  echo
  echo "NO WIRING PERFORMED IN THIS STEP."
} > "$OUTPUT"

echo "Wrote $OUTPUT"
