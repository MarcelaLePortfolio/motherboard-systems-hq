
#!/usr/bin/env bash

set -euo pipefail

REPORT="governance-approval-ontology-report.txt"

{

  echo "GOVERNANCE APPROVAL ONTOLOGY INSPECTION"

  echo

  echo "--- branch ---"

  git branch --show-current

  echo

  echo "--- recent governance-related commits ---"

  git log --oneline --decorate --all --grep="governance\|preview\|approval\|envelope\|delegation\|artifact\|execution" -i | head -200

  echo

  echo "--- repo search: approval ---"

  rg -n -i "approval|approve|approved" . || true

  echo

  echo "--- repo search: preview ---"

  rg -n -i "preview|planning preview|execution preview" . || true

  echo

  echo "--- repo search: governance artifact ---"

  rg -n -i "governance artifact|artifact" . || true

  echo

  echo "--- repo search: delegation / envelope ---"

  rg -n -i "delegation|delegate|envelope" . || true

  echo

  echo "--- repo search: execution authorization ---"

  rg -n -i "execution authorization|authorize execution|execution approval" . || true

  echo

  echo "--- repo search: ontology findings ---"

  rg -n -i "ontology|state transition|governance event|authority transfer|interpretation authorization" . || true

  echo

  echo "--- repo search: plan -> preview -> execution language ---"

  rg -n -i "plan.*preview|preview.*execution|approve.*preview|approve.*plan|approval.*execution" . || true

} | tee "$REPORT"

echo

echo "Report written to: $REPORT"

