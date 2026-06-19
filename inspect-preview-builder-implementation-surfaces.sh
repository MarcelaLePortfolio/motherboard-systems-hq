
#!/usr/bin/env bash

set -euo pipefail

REPORT="preview-builder-implementation-surfaces-inspection.txt"

{

  echo "PREVIEW BUILDER IMPLEMENTATION SURFACES INSPECTION"

  echo

  echo "--- current head ---"

  git log --oneline -8

  echo

  echo "--- governed planning route / pipeline surfaces ---"

  rg -n "runGovernedPlanningPipeline|buildGovernedPlanningArtifactBundle|buildApprovalArtifact|evaluateExecutionApproval|planCadeEngineeringExecution|buildExecutionEnvelopeDraft" server/routes server/execution server/contracts || true

  echo

  echo "--- current preview / approval UI surfaces ---"

  rg -n -i "planning-preview|approval|approve|modal|preview-confirmation|future state|meaning" public/js public/dashboard.html || true

  echo

  echo "--- authority and phase transition surfaces ---"

  rg -n -i "approval_gated|planning_completed|mutation_authorized|execution_authority|authorization|authority|phase" server/execution server/contracts || true

  echo

  echo "--- current documented lifecycle findings ---"

  ls -1 *finding.txt | rg -i "preview|interpretation|authorization|approval|future|governance|builder" || true

} | tee "$REPORT"

cat > preview-builder-implementation-surfaces-finding.txt << 'EOF'

PREVIEW BUILDER IMPLEMENTATION SURFACES FINDING

Finding Status: INSPECTION ONLY

Purpose:

Identify likely implementation attachment points for the reconciled lifecycle:

- Interpretation-First Approval / Meaning Review

- Future-State Review

- Execution Authorization

Inspection targets:

- governed planning route

- governed planning pipeline

- execution envelope draft

- approval artifact builder

- approval gate

- Cade planning adapter

- governed planning artifact bundle

- current planning preview card

- current dashboard modal surfaces

- authority and phase transition files

Scope boundaries:

This inspection does not authorize:

- implementation

- UI work

- approval system construction

- Preview Builder construction

- mutation

- shell execution

- autonomous execution

