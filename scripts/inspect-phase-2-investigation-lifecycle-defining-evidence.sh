#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== PHASE 2 — INVESTIGATION LIFECYCLE DEFINING EVIDENCE ==="

REQUIRED_ANCESTOR="87a3fefe"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain Phase 2 reconciliation checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/inspect-phase-2-investigation-lifecycle-defining-evidence\.sh$|^ M scripts/inspect-phase-2-investigation-lifecycle-defining-evidence\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_INSPECTION_SCRIPT_ONLY"

echo
echo "=== CANDIDATE INVESTIGATION CAPABILITY MODEL ==="
sed -n '1,260p' \
  docs/governance/CANDIDATE_INVESTIGATION_CAPABILITY_MODEL.md

echo
echo "=== CANDIDATE INVESTIGATION STATE SHIFT OBSERVATION ==="
sed -n '1,260p' \
  docs/governance/CANDIDATE_INVESTIGATION_STATE_SHIFT_OBSERVATION.md

echo
echo "=== CANDIDATE INVESTIGATION OBSERVABILITY SEPARATION ==="
sed -n '1,260p' \
  docs/governance/CANDIDATE_INVESTIGATION_OBSERVABILITY_SEPARATION.md

echo
echo "=== CANDIDATE V3 LINEAGE — INVESTIGATION REFERENCES ==="
grep -n -C 8 -Ei \
  'Investigation Lifecycle|investigation|state shift|observability|active question|resolution|uncertainty|evidence' \
  docs/governance/CANDIDATE_V3_COLLABORATION_MODE_LINEAGE_INVESTIGATION.md || true

echo
echo "=== V2 EVIDENCE LEDGER — INVESTIGATION REFERENCES ==="
grep -n -C 8 -Ei \
  'Investigation Lifecycle|investigation|state shift|observability|active question|resolution|uncertainty|evidence' \
  docs/governance/MATILDA_COLLABORATION_MODE_V2_EVIDENCE_LEDGER.md || true

echo
echo "=== CURRENT PHASE 2 TRANSITION CONTRACT ==="
sed -n '130,230p' \
  scripts/classify-phase-1-response-composition-state.sh

echo
echo "=== PHASE 1 CLOSURE TRANSITION CONTRACT ==="
sed -n '90,145p' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== INTERPRETATION LIFECYCLE RUNTIME ==="
sed -n '1,380p' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== CONVERSATION CONTEXT RUNTIME ==="
sed -n '1,150p' \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== AUTHORITY + CONTAMINATION EVALUATORS ==="
cat server/matilda-history-authority-evaluator.ts
cat server/matilda-history-contamination-evaluator.ts

echo
echo "=== WORKFLOW INVESTIGATION-RELEVANT PERSISTENCE ==="
sed -n '145,285p' \
  server/matilda-chat-workflow.ts

echo
echo "=== LIVING DRAFT UNRESOLVED-QUESTION FLOW ==="
grep -n -C 5 \
  'unresolved_questions' \
  db/matilda-draft-synthesis-runtime.ts \
  db/matilda-living-draft-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts || true

echo
echo "=== DEDICATED INVESTIGATION RUNTIME SEARCH ==="
find server db routes -type f \
  \( -iname '*investigation*' -o -iname '*collaboration*runtime*' \) \
  -print | sort

echo
echo "=== INVESTIGATION STATE SYMBOL SEARCH ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -Ei \
  'investigation_(id|status|state)|investigation(Id|Status|State)|activeInvestigation|active_investigation|openInvestigation|closeInvestigation|investigationEvidence|investigation_evidence' \
  server db routes 2>/dev/null || true

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during Phase 2 defining-evidence inspection."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "PHASE_2_INVESTIGATION_LIFECYCLE_DEFINING_EVIDENCE_COLLECTED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_PHASE_2_INVESTIGATION_LIFECYCLE_CURRENT_STATE"

git add scripts/inspect-phase-2-investigation-lifecycle-defining-evidence.sh
git commit -m "Inspect Phase 2 Investigation Lifecycle defining evidence"
git push
