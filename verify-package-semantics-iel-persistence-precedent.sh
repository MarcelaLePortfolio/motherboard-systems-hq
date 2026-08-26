#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VERIFY PACKAGE SEMANTICS IEL PERSISTENCE PRECEDENT ==="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "RECOVERY_POINT=DR_20260826_092915"

echo
echo "=== EXISTING IEL SCHEMA / JSON ARTIFACT PRECEDENT ==="
rg -n -C 12 \
  'investigation_lifecycle_json|CREATE TABLE.*interpretation|interpretation_evidence_ledger|matilda_observation|supporting_raw_evidence|unresolved_questions|lineage_references' \
  db server \
  -g '*.ts' \
  2>/dev/null || true

echo
echo "=== IEL WRITE PATH ==="
rg -n -C 12 \
  'createInterpretationEvidenceLedgerEntry|investigation_lifecycle_json|investigationLifecycle|supporting_raw_evidence|matilda_observation' \
  db server \
  -g '*.ts' \
  2>/dev/null || true

echo
echo "=== IEL READ / RECONSTRUCTION PATH ==="
rg -n -C 12 \
  'listInterpretationEvidenceLedgerEntries|investigation_lifecycle_json|validateMatildaInvestigationLifecycleArtifact|investigationLifecycle' \
  db server \
  -g '*.ts' \
  2>/dev/null || true

echo
echo "=== TARGET PERSISTENCE CLASSIFICATION ==="
echo "CANDIDATE_COLUMN=package_semantics_json"
echo "COLUMN_NULLABLE=YES"
echo "HISTORICAL_ROWS=SQL_NULL_NO_BACKFILL"
echo "WRITE_OWNER=EXISTING_WORKFLOW_IEL_PERSISTENCE"
echo "READ_OWNER=EXISTING_IEL_RECONSTRUCTION_PATH"
echo "VALIDATOR=DEDICATED_PACKAGE_SEMANTICS_VALIDATOR"
echo "SUPPORTING_RAW_EVIDENCE_REPURPOSED=NO"
echo "SECOND_IEL_ENTRY_PER_TURN=NO"
echo "ONE_WORKFLOW_ONE_IEL_ENTRY=PRESERVED"
echo "ONE_OLLAMA_INVOCATION=PRESERVED"

echo
echo "=== BOUNDARY ==="
echo "IEL_SCHEMA_CHANGE_AUTHORIZED=NO"
echo "OLLAMA_CONTRACT_CHANGE_AUTHORIZED=NO"
echo "WORKFLOW_CHANGE_AUTHORIZED=NO"
echo "SYNTHESIS_CHANGE_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_END_TO_END_PACKAGE_SEMANTICS_TRANSPORT_UNIT_IF_PERSISTENCE_PRECEDENT_IS_CONFIRMED"
