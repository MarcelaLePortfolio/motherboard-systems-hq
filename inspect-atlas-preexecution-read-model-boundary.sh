#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"

echo "===== ATLAS PRE-EXECUTION READ MODEL — EXACT BOUNDARY INSPECTION ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "===== CURRENT ATLAS PRODUCERS / CONSUMERS / READ MODELS ====="
grep -RniE \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.js' \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  'ExecutionEvent|execution.?event|Atlas|atlas|reconstructWhy|trajectory|narrative|cartograph|knowledge' \
  server db routes scripts 2>/dev/null | head -n 1200 || true

echo
echo "===== PRE-EXECUTION DURABLE SOURCES ====="
grep -RniE \
  --include='*.ts' \
  --exclude='*.test.ts' \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  'matilda_interpretation_evidence_ledger|investigation_lifecycle_json|package_semantics_json|matilda_living_draft_packages|matilda_draft_revisions|matilda_canonical_packages|governance_packages' \
  server db routes scripts 2>/dev/null | head -n 1200 || true

echo
echo "===== SEARCH FOR EXISTING PRE-EXECUTION -> ATLAS BRIDGE ====="
grep -RniE \
  --include='*.ts' \
  --include='*.tsx' \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  '(interpretation|living.?draft|canonical.?package|investigation.?lifecycle|package.?semantics).{0,120}(atlas|trajectory|narrative|cartograph)|(atlas|trajectory|narrative|cartograph).{0,120}(interpretation|living.?draft|canonical.?package|investigation.?lifecycle|package.?semantics)' \
  server db routes scripts 2>/dev/null || true

echo
echo "===== CLASSIFICATION TARGET ====="
echo "Q1=WHAT_EXACT_FUNCTION_OR_MODULE_DEFINES_CURRENT_ATLAS_INPUT"
echo "Q2=WHERE_ARE_EXECUTION_EVENTS_LOADED_FOR_ATLAS"
echo "Q3=IS_ATLAS_INPUT_TYPED_EXCLUSIVELY_AS_EXECUTION_EVENTS"
echo "Q4=DOES_ANY_EXISTING_PRODUCER_TRANSLATE_PREEXECUTION_DURABLE_STATE_INTO_ATLAS_OBSERVATIONS"
echo "Q5=CAN_PREEXECUTION_STATE_BE_READ_NON_AUTHORITATIVELY_WITHOUT_MUTATING_MATILDA_OR_GOVERNANCE_STATE"
echo "Q6=WHAT_IS_THE_MINIMUM_EXISTING_BOUNDARY_WHERE_A_PREEXECUTION_READ_MODEL_COULD_JOIN_ATLAS"
echo
echo "IF_NO_BRIDGE_EXISTS=CLASSIFY_ATLAS_PREEXECUTION_READ_MODEL_BRIDGE_AS_PRIMARY_MISSING_CAPABILITY"
echo "IF_BRIDGE_EXISTS=TRACE_WHY_IT_IS_NOT_RECEIVING_OR_EXPOSING_PREEXECUTION_STATE"
echo
echo "SAFETY_BOUNDARY=OBSERVATION_ONLY_NON_AUTHORITATIVE"
echo "MATILDA_AUTHORITY_CHANGE=NO"
echo "GOVERNANCE_AUTHORITY_CHANGE=NO"
echo "EXECUTION_AUTHORITY_CHANGE=NO"
echo "DATABASE_CHANGE=NO"
echo "SOURCE_CHANGE=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_Q1_THROUGH_Q6_FROM_EXACT_RUNTIME_EVIDENCE"

echo
echo "===== WORKTREE ====="
git status --short
