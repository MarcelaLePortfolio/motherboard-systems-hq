#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase465_6_exact_owner_snippets.txt"

INTAKE_FILE="server/taskContract.mjs"
GOVERNANCE_FILE="server/policy/policy_eval.mjs"
EXECUTION_FILE="server/orchestration/policy-pipeline.ts"

mkdir -p docs

{
  echo "PHASE 465.6 — EXACT OWNER SNIPPET EXTRACTION"
  echo "============================================"
  echo
  echo "SELECTED OWNERS"
  echo "- Intake: $INTAKE_FILE"
  echo "- Governance: $GOVERNANCE_FILE"
  echo "- Execution/Preparation: $EXECUTION_FILE"
  echo
  echo "SELECTION BASIS"
  echo "- Intake owner selected from shortlist because it contains normalize/validate task contract logic."
  echo "- Governance owner selected from shortlist because it is the strongest live policy evaluation surface."
  echo "- Execution/preparation owner selected from live orchestration surfaces rather than SQL false positives."
  echo

  for FILE in "$INTAKE_FILE" "$GOVERNANCE_FILE" "$EXECUTION_FILE"; do
    echo "FILE: $FILE"
    echo "----------------------------------------"

    if [ ! -f "$FILE" ]; then
      echo "MISSING: $FILE"
      echo
      continue
    fi

    echo "1) High-signal lines"
    rg -n 'normalize|validate|policy|evaluate|decision|authorization|eligible|prepare|ready|execute|run|dispatch|task|pipeline' "$FILE" || true
    echo

    echo "2) Focused excerpts"
    while IFS=: read -r line _; do
      start=$(( line > 20 ? line - 20 : 1 ))
      end=$(( line + 40 ))
      echo "----- ${FILE} lines ${start}-${end} -----"
      sed -n "${start},${end}p" "$FILE"
      echo
    done < <(
      rg -n 'normalize|validate|policy|evaluate|decision|authorization|eligible|prepare|ready|execute|run|dispatch|task|pipeline' "$FILE" \
      | cut -d: -f1 \
      | awk '!seen[$0]++' \
      | head -n 12
    )

    echo
  done

  echo "DECISION TARGET"
  echo "- Confirm whether these three files are the true disconnected boundary owners."
  echo "- Next phase should define the explicit structural bridge contract between these owners only."
} > "$OUT"

echo "Wrote $OUT"
