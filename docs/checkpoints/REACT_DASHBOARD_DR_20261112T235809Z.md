# React Dashboard Disaster Recovery Checkpoint

## Recovery classification

Protected React dashboard restored and operator-confirmed.

## Immutable operating boundaries

- Preserve the last known working production runtime.
- Require evidence before modifying routes or authentication.
- Keep unrelated dirty-worktree changes intact.
- Never use broad reset, clean, or stash operations for this recovery.
- Limit repeated failed hypotheses and revert when evidence does not support another attempt.
- Separate collaboration and inspection from explicitly authorized execution.

## Recovery requirements

A valid recovery must restore the React `/ui` entrypoint, its built assets, and the Cloudflare Access authentication boundary together.

A working legacy inline dashboard is not an acceptable substitute.

## Verification gates

1. Confirm repository branch and exact commit.
2. Confirm the current production listener and compiled runtime.
3. Confirm React build assets exist.
4. Run `bash scripts/verify-react-dashboard-route.sh`.
5. Confirm unauthenticated dashboard, asset, and API requests return HTTP 401.
6. Confirm the intended dashboard renders through authenticated browser access.
7. Preserve an independently recoverable runtime backup before any future restart.

## Git checkpoint status

Documentation and guard files are not automatically committed by this capture.

A subsequent scoped commit must include the verified React route restoration, its authentication dependency, the regression guard, workflow, and recovery documentation without staging unrelated changes.

## DR status

Local recovery evidence captured. Durable remote Git checkpoint and independent recovery rehearsal remain pending.

## Captured runtime evidence

- UTC: 20261112T235809Z
- Branch: feature/support-source-references-runtime
- HEAD: 3e204e807d2279f114e08332429cca10cb38e090
- Runtime SHA256: 0c5d0771d05a0309d8c797de651aee89db4fcfd1d415ef9a271fd356d331145c
- Production PID: 98707
- Rollback checkpoint: /var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T/dashboard-restore.tZp7D5rc

## Current worktree status

```text
 M .DS_Store
 M client/vite.config.ts
 M scripts/diagnose-live-selected-context-identities.ts
 M scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts
 M scripts/utils/ollamaChat.structured-evidence-object.test.ts
 M scripts/validate-package-semantics-grounding-under-proven-runner.sh
 M scripts/verify-matilda-upstream-reconciliation-readiness.sh
 M server/index.ts
 M server/routes/governance-lifecycle-route.ts
 M snapshots/20251114-114707/db/main.db
 M snapshots/20251114-114707/db/main.db-shm
 M snapshots/20251114-114707/db/main.db-wal
 M snapshots/20251114-114821/db/main.db
 M snapshots/20251114-114821/db/main.db-shm
 M snapshots/20251114-114821/db/main.db-wal
?? .github/workflows/react-dashboard-route-contract.yml
?? ELLIS_CORRIDOR_3_CLOSURE_STATUS.txt
?? ELLIS_PRODUCTION_INTEGRATION_SCOPE_REVIEW.txt
?? ELLIS_STAGE3_ADMINISTRATIVE_AUDIT_PROTECTION_DESIGN_GATE.md
?? ELLIS_STAGE3_AUTHORITY_COMPOSITION_LIFECYCLE_INSPECTION.md
?? ELLIS_STAGE3_CREDENTIAL_BINDING_DECISION.md
?? ELLIS_STAGE3_DEPARTMENT_ADMISSION_EXECUTION_COMPOSITION_RECONCILIATION.md
?? ELLIS_STAGE3_DEPARTMENT_PROVIDER_PERSISTENCE_CONTRACT_RECONCILIATION.md
?? ELLIS_STAGE3_ENCRYPTED_BACKUP_CUSTODY_DESIGN_GATE.md
?? ELLIS_STAGE3_EVIDENCE_FIRST_SOURCE_INSPECTION.md
?? ELLIS_STAGE3_EXISTING_CREDENTIAL_DISPOSITION_DESIGN_GATE.md
?? ELLIS_STAGE3_EXISTING_TRUST_SOURCE_ASSESSMENT.md
?? ELLIS_STAGE3_FINAL_DESIGN_GOVERNANCE_RECONCILIATION.md
?? ELLIS_STAGE3_GOVERNANCE_EVIDENCE_MATRIX.md
?? ELLIS_STAGE3_GOVERNANCE_RECONCILIATION_AFTER_DESIGN_GATES.md
?? ELLIS_STAGE3_GOVERNANCE_RECONCILIATION_EVIDENCE.md
?? ELLIS_STAGE3_GOVERNED_OPERATIONAL_SEQUENCE.md
?? ELLIS_STAGE3_HOST_COMPROMISE_RESIDUAL_RISK_DESIGN_GATE.md
?? ELLIS_STAGE3_HOST_INDEPENDENCE_DESIGN_APPROVAL.md
?? ELLIS_STAGE3_HUMAN_APPROVAL_BINDING_DESIGN.md
?? ELLIS_STAGE3_HUMAN_AUTHORITY_PROVENANCE_CONTRACT_RECONCILIATION.md
?? ELLIS_STAGE3_INDEPENDENT_ADMINISTRATIVE_PROVENANCE_ACCEPTANCE.md
?? ELLIS_STAGE3_INDEPENDENT_ADMINISTRATIVE_PROVENANCE_APPROVAL.md
?? ELLIS_STAGE3_INDEPENDENT_ADMINISTRATIVE_TRUST_SOURCE_APPROVAL.md
?? ELLIS_STAGE3_INDEPENDENT_ADMINISTRATIVE_TRUST_SOURCE_DECISION_GATE.md
?? ELLIS_STAGE3_INDEPENDENT_EMERGENCY_REVOCATION_DESIGN_GATE.md
?? ELLIS_STAGE3_INDEPENDENT_HUMAN_CONFIRMATION_DESIGN.md
?? ELLIS_STAGE3_INDEPENDENT_TRUST_SOURCE_OPTIONS_EVALUATION.md
?? ELLIS_STAGE3_INDEPENDENT_TRUST_SOURCE_SCOPE_PLAN.md
?? ELLIS_STAGE3_KEY_VALIDITY_HISTORICAL_SIGNATURE_DESIGN_GATE.md
?? ELLIS_STAGE3_LOCAL_SIGNER_DECISION.txt
?? ELLIS_STAGE3_MANIFEST_CRYPTOGRAPHIC_DESIGN.md
?? ELLIS_STAGE3_MANUAL_LOCAL_SIGNER_DECISION.md
?? ELLIS_STAGE3_MANUAL_LOCAL_SIGNER_DESIGN.md
?? ELLIS_STAGE3_NON_PRODUCTION_RECOVERY_VALIDATION_DESIGN_GATE.md
?? ELLIS_STAGE3_OPERATIONAL_DESIGN_DECISION_REGISTER.md
?? ELLIS_STAGE3_OPERATIONAL_MECHANISM_DESIGN_GATE.md
?? ELLIS_STAGE3_PAUSE_PERSISTENCE_CHECKPOINT.md
?? ELLIS_STAGE3_POST_TRUST_SOURCE_APPROVAL_CLOSURE_READINESS.md
?? ELLIS_STAGE3_PRODUCTION_COMPOSITION_RECONCILIATION.md
?? ELLIS_STAGE3_PRODUCTION_STARTUP_AUTHORITY_RECONCILIATION.md
?? ELLIS_STAGE3_PRODUCTION_STARTUP_AUTHORITY_SOURCE_INSPECTION.md
?? ELLIS_STAGE3_PROTECTED_KEY_BACKUP_RECOVERY_DESIGN.md
?? ELLIS_STAGE3_PROVIDER_OWNERSHIP_TRUST_ANCHOR_RECONCILIATION.md
?? ELLIS_STAGE3_PROVIDER_TRUST_ROUTE_RECONCILIATION.md
?? ELLIS_STAGE3_RECOVERY_AUTHENTICATION_DESIGN_GATE.md
?? ELLIS_STAGE3_REMAINING_GOVERNANCE_GAPS_INSPECTION.md
?? ELLIS_STAGE3_REVOCATION_AND_KEY_ROTATION_DESIGN.md
?? ELLIS_STAGE3_SIGNER_BOUNDARY_RECOMMENDATION.txt
?? ELLIS_STAGE3_SINGLE_USE_AUTHORIZATION_DESIGN.md
?? ELLIS_STAGE3_SOURCE_INSPECTION_RECONCILIATION.md
?? ELLIS_STAGE3_THREAT_MODEL_REVIEW.md
?? ELLIS_STAGE3_TRUSTED_REGISTRY_DESIGN_DECISION_GATE.md
?? ELLIS_STAGE3_TRUST_ANCHOR_CLOSURE_GATE_INSPECTION.md
?? ELLIS_STAGE3_TRUST_SOURCE_IMPLEMENTATION_INVENTORY_RECONCILIATION.md
?? apply-isolated-execution-registry-integrity-repair.sh
?? backups/pre-clean-slate-20260901T225905Z/
?? begin-decisions-list-title-compactness-investigation.sh
?? capture-atlas-lifecycle-validation-result.sh
?? classify-execution-registry-transition-integrity.sh
?? commit-authorized-atlas-lifecycle-test-restoration.sh
?? commit-pending-validation-eligibility-repair.sh
?? commit-push-atlas-historical-adapter.sh
?? db/governance-department-credential-persistence.test.ts
?? db/governance-department-credential-persistence.ts
?? db/governance-ellis-acknowledgement-persistence.test.ts
?? db/governance-ellis-acknowledgement-persistence.ts
?? db/governance-ellis-assignment-persistence.test.ts
?? db/governance-ellis-assignment-persistence.ts
?? db/governance-ellis-verified-lifecycle-persistence.test.ts
?? db/governance-ellis-verified-lifecycle-persistence.ts
?? db/main.db.pre-dogfood-cleanup-20260914_140324.bak
?? db/main.db.pre-executive-inbox-repair.20261014_221205.bak
?? db/main.db.pre-governance-fk-repair.20260831_141331.bak
?? db/main.db.pre-operational-package-authority-20260825_140352.bak
?? db/main.db.pre-project-scoped-delegation-20260825_105613.bak
?? db/main_backup_before_rebuild.sqlite-shm
?? db/main_backup_before_rebuild.sqlite-wal
?? db/main_backup_before_reflection_fix.sqlite-shm
?? db/main_backup_before_reflection_fix.sqlite-wal
?? db/main_backup_before_type_patch.sqlite-shm
?? db/main_backup_before_type_patch.sqlite-wal
?? define-bounded-atlas-lifecycle-test-restoration.sh
?? determine-empty-transition-stabilization-intent.sh
?? diagnose-atlas-attempt2-exact-ollama-binding.sh
?? diagnose-atlas-lifecycle-attempt1-sqlite-error.sh
?? diagnose-atlas-lifecycle-sqlite-error-after-snapshot-fix.sh
?? diagnose-atlas-lifecycle-temp-schema-mismatch.sh
?? diagnose-authorized-atlas-test-commit-not-landed.sh
?? dist.prev-49069cade/
?? dist.prev-968137bdd/
?? dist.prev-clean-d89b9119b/
?? dist.prev-d89b9119b/
?? dist.prev-h2/
?? docs/checkpoints/ELLIS_DOWNSTREAM_SUCCESS_PATH_CONTRACT_INSPECTION.md
?? docs/checkpoints/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_3_CLOSURE.md
?? docs/checkpoints/MATILDA_ISOLATED_PROJECT_CONTEXT_RETRIEVAL_VALIDATION.md
?? docs/checkpoints/PARENT_DEVELOPMENT_SEQUENCE_RESUMPTION.md
?? docs/checkpoints/REACT_DASHBOARD_DR_20261112T235809Z.md
?? docs/checkpoints/REACT_DASHBOARD_RESTORATION_20261112T235809Z.md
?? docs/checkpoints/STAGE_10_CLOUDFLARE_ACCESS_SECURITY_CLOSURE_20261111.md
?? docs/governance/DEPARTMENT_ACKNOWLEDGEMENT_DESIGN_CHECKPOINT.md
?? docs/governance/DEPARTMENT_ACKNOWLEDGEMENT_PROVENANCE_REASSESSMENT.md
?? docs/governance/DEPARTMENT_ACKNOWLEDGEMENT_TRUSTED_PROVENANCE_DESIGN.md
?? docs/governance/DEPARTMENT_IDENTITY_ASSIGNMENT_ARCHITECTURAL_RESOLUTION.md
?? docs/governance/ELLIS_AI_EMPLOYEE_IDENTITY_DECISION_20261016.md
?? docs/governance/ELLIS_CORRIDOR_4_STAGE_3_CRYPTOGRAPHIC_REGISTRATION_VALIDATION_20261016.md
?? docs/governance/ELLIS_CORRIDOR_4_STAGE_3_INDEPENDENT_AUTHORITY_ESTABLISHMENT_FINDINGS_20261016.md
?? docs/governance/ELLIS_CORRIDOR_4_STAGE_3_PROVIDER_TRUST_VALIDATION_20261016.md
?? docs/governance/ELLIS_CORRIDOR_4_STAGE_3_TRUST_ANCHOR_VALIDATION_20261016.md
?? docs/governance/ELLIS_CREDENTIAL_AUTHORITY_RECOMMENDATION_20261016.md
?? docs/governance/ELLIS_FINAL_PRODUCTION_ARCHITECTURE_REVIEW_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_1_CLOSURE_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_2_CLOSURE_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_2_SCOPE_REVIEW_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_3_SCOPE_DETERMINATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_ADMINISTRATOR_DECISION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_CREDENTIAL_AUTHORITY_DECISION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_CREDENTIAL_LIFECYCLE_DESIGN_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_CREDENTIAL_SCHEMA_APPROVAL_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_CREDENTIAL_SCHEMA_PROPOSAL_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_FINAL_CREDENTIAL_SCHEMA_REVIEW_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_IMPLEMENTATION_SCOPE_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_IMPLEMENTATION_SCOPE_APPROVAL_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_LIFECYCLE_APPROVAL_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_REVOCATION_POLICY_APPROVAL_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_REVOCATION_POLICY_PROPOSAL_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_REVOCATION_RECOVERY_DECISION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_SCHEMA_SECURITY_RECONCILIATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_SCOPE_DETERMINATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_1_FINDINGS_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_2A_CLOSURE_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_2A_SECURITY_REVIEW_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_2A_VALIDATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_AUTHORITY_GATE_FINDINGS_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_AUTHORITY_MIDDLEWARE_REVIEW_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_CLOSURE_GATE_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_CRYPTOGRAPHIC_VALIDATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_HUMAN_AUTHORITY_VALIDATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_INDEPENDENT_AUTHORITY_VALIDATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_OWNERSHIP_VALIDATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_SECURITY_FINDINGS_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_TRUST_BOUNDARY_INSPECTION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_TRUST_CONTRACT_VALIDATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_TRUST_DECISION_GATE_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STAGE_3_VALIDATION_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_CORRIDOR_4_STORAGE_FINDINGS_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_DECISION_RECORD_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_DESIGN_20261016.md
?? docs/governance/ELLIS_PRODUCTION_INTEGRATION_READINESS_20261016.md
?? docs/governance/ELLIS_VERIFIED_DEPARTMENT_ASSIGNMENT_CORRIDORS_1_2_CHECKPOINT.md
?? docs/governance/ELLIS_VERIFIED_EVIDENCE_BINDING_CONTRACT_20261016.md
?? docs/handoffs/
?? execute-atlas-lifecycle-attempt1-and-capture.sh
?? handoffs/MATILDA_ADMISSION_SUPPORT_FIREWALL_CLAUDE_REVIEW_20260902.zip
?? handoffs/MATILDA_ADMISSION_SUPPORT_FIREWALL_CLAUDE_REVIEW_20260902/
?? handoffs/MATILDA_COLLABORATION_RELIABILITY_CLAUDE_BUNDLE.zip
?? handoffs/MATILDA_COLLABORATION_RELIABILITY_CLAUDE_REVIEW_20260902.zip
?? handoffs/MATILDA_COLLABORATION_RELIABILITY_CLAUDE_REVIEW_20260902/
?? handoffs/MATILDA_PER_ITEM_SUPPORT_FLAG_POST_EXPERIMENT_CLAUDE_REVIEW_20260903.zip
?? handoffs/MATILDA_SUPPORT_BEARING_SUBSET_FAILED_EXPERIMENT_CLAUDE_REVIEW_20260902.zip
?? implement-approvals-ui-recomposition.sh
?? implement-atlas-canonical-package-observation-attempt-1.sh
?? implement-atlas-draft-approval-adapter-attempt-1.sh
?? implement-atlas-historical-observation-adapter-attempt-1.sh
?? implement-atlas-lifecycle-test-attempt-2.sh
?? implement-atlas-preexecution-observation-aggregator-attempt-1.sh
?? implement-atlas-preexecution-read-route-attempt-1.sh
?? implement-atlas-preexecution-structural-reasoner-attempt-1.sh
?? implement-atlas-workflow-integration-attempt-1.sh
?? implement-authorized-atlas-fixture-canonical-schema-restoration.sh
?? implement-ellis-corridor-3-isolated.sh
?? implement-envelope-gate-validation-eligibility-attempt-1.sh
?? implement-envelope-gate-validation-eligibility-attempt-2.sh
?? implement-envelope-gate-validation-eligibility-attempt-3.sh
?? implement-executive-delegation-decision-adapter.sh
?? implement-explicit-operator-validation-attempt-1.sh
?? implement-option-b-typed-user-package-semantics.sh
?? implement-package-semantics-conditional-completeness-attempt-2.sh
?? implement-package-semantics-conditional-completeness.sh
?? implement-validation-eligibility-atomic-attempt-1.sh
?? implement-validation-eligibility-attempt-2.sh
?? implement-validation-eligibility-attempt-3.sh
?? inspect-atlas-attempt-1-post-repair-state.sh
?? inspect-atlas-historical-adapter-final-boundary.sh
?? inspect-atlas-historical-runtime-merge-exact-contract.sh
?? inspect-atlas-preexecution-exact-joins.sh
?? inspect-atlas-qa-lifecycle-remaining-work.sh
?? inspect-atlas-safe-dogfood-validation-seam.sh
?? inspect-authoritative-approval-transition-and-registry-fields.sh
?? inspect-current-entity-reconciliation-lineage.sh
?? inspect-current-vs-historical-validation-operator-adapter.sh
?? inspect-decisions-list-compact-title-after-attempt-2-pattern-miss.sh
?? inspect-ellis-authority-decision-readonly.sh
?? inspect-ellis-baseline-readonly.sh
?? inspect-ellis-corridor-3-admission-contract.sh
?? inspect-ellis-corridor-3-readonly.sh
?? inspect-ellis-department-identity-boundary.sh
?? inspect-ellis-existing-signing-infrastructure.sh
?? inspect-ellis-local-signer-prerequisites.sh
?? inspect-ellis-macos-signer-boundary.sh
?? inspect-ellis-next-boundaries-readonly.sh
?? inspect-ellis-signing-isolation-readonly.sh
?? inspect-ellis-stage3-authority-readonly.sh
?? inspect-ellis-stage3-hosting-feasibility.sh
?? inspect-ellis-verified-assignment-integration.sh
?? inspect-execution-registry-repair-result.sh
?? inspect-historical-operator-validation-adapter.sh
?? inspect-option-b-attempt-1-scope-failure.sh
?? inspect-option-b-exact-function-entry-before-attempt-2.sh
?? inspect-package-semantics-live-revalidation-method.sh
?? inspect-pre-orchestrator-authority-and-project-identity-gap.sh
?? inspect-seeded-package-semantics.sh
?? inspect-validation-adapter-removal-lineage.sh
?? investigate-canonical-package-delegation-boundary.sh
?? investigate-dual-approval-item-reconciliation.sh
?? investigate-packages-tab-reconciliation.sh
?? investigate-semantic-history-final-depth.sh
?? motherboard.db
?? print-existing-envelope-lifecycle-shared-caller.sh
?? print-lifecycle-input-ownership-only.sh
?? prototypes/ellis-stage3-iphone-feasibility/
?? prove-atlas-bounded-dogfood-seam.sh
?? reattempt-validation-eligibility-under-proven-runner.sh
?? reconcile-live-phase-4-state.sh
?? reconcile-parent-sequence-successor.sh
?? record-approvals-browser-validation-result.sh
?? record-atlas-ui-manual-checkpoint.sh
?? repair-approvals-react-recomposition.sh
?? repair-atlas-preexecution-http-mount-attempt-1.sh
?? repair-atlas-preexecution-observation-aggregator-attempt-1.sh
?? repair-atlas-preexecution-observation-aggregator-attempt-1b.sh
?? repair-atlas-preexecution-observation-aggregator-attempt-1c.sh
?? repair-atlas-preexecution-observation-aggregator-attempt-1d.sh
?? repair-draft-revision-test-fixtures.sh
?? repair-ellis-bounded-correction.sh
?? repair-validation-route-loader-test-seam.sh
?? restore-bounded-atlas-lifecycle-validation.sh
?? retry-authorized-atlas-lifecycle-test-attempt-3.sh
?? revalidate-package-semantics-live-seed.sh
?? revalidate-package-semantics-live-seed.ts
?? revert-atlas-lifecycle-test-after-attempt3.sh
?? review-point-4-investigation-output.sh
?? run-pre-dr-capture.sh
?? scripts/_local/repair-corridor-3-option-a-attempt-2.sh
?? scripts/capture-single-grounding-dogfood-result.sh
?? scripts/classify-corridor-6-execution-field-authority-status.sh
?? scripts/classify-corridor-6-minimum-execution-approval-transition-unit.sh
?? scripts/fix-conditional-conversation-prompt-test-fixtures.sh
?? scripts/implement-conditional-conversation-turn-prompt-instruction.sh
?? scripts/implement-corridor-3-existing-commit-push-entry-point.sh
?? scripts/implement-corridor-6-third-runtime-hypothesis.sh
?? scripts/implement-expected-outcome-diagnostic-observability.sh
?? scripts/inspect-corridor-2-current-durable-authorization-contract.sh
?? scripts/inspect-corridor-6-approval-transition-implementation-boundaries.sh
?? scripts/inspect-corridor-6-authoritative-execution-field-sources-focused.sh
?? scripts/inspect-corridor-6-dedicated-route-binding-boundaries.sh
?? scripts/inspect-corridor-6-exact-approval-persistence-insertion-boundary.sh
?? scripts/inspect-corridor-6-full-envelope-reconstruction-source.sh
?? scripts/inspect-corridor-6-package-to-execution-authority-mapping.sh
?? scripts/inspect-corridor-6-unexpected-head.sh
?? scripts/inspect-empty-history-revert-causality.sh
?? scripts/inspect-package-semantics-grounding-revert-boundary.sh
?? scripts/investigate-corridor-6-durable-execution-envelope-authority-sources.sh
?? scripts/investigate-corridor-6-self-improvement-execution-activation-closure.sh
?? scripts/investigate-empty-history-model-output-contract.sh
?? scripts/investigate-live-expected-outcome-fidelity-failure.sh
?? scripts/reconcile-active-schema-bounding-runtime.sh
?? scripts/reconcile-corridor-2-authorization-closure-history.sh
?? scripts/reconcile-corridor-6-after-corridor-2-authority-correction.sh
?? scripts/reconcile-corridor-6-existing-execution-approval-transition.sh
?? scripts/repair-corridor-6-route-mount-checkpoint-verification.sh
?? scripts/repair-corridor-6-third-hypothesis-equivalence-check.sh
?? scripts/repair-living-draft-success-criteria-schema-entry.sh
?? scripts/repair-reconciled-success-criteria-fixture.sh
?? scripts/revalidate-attempt-2-macos-compatible.sh
?? scripts/run-packages-tab-unseeded-characterization.ts
?? scripts/run-positional-selection-live-characterization.ts
?? scripts/run-support-bearing-subset-characterization.ts
?? scripts/utils/ollamaChat.duplicate-child-enumeration-isolation-experiment.ts
?? scripts/utils/ollamaChat.duplicate-parent-enumeration-isolation-experiment.ts
?? scripts/utils/ollamaChat.parent-identity-removal-experiment.ts
?? scripts/utils/ollamaChat.per-item-support-flag-experiment.ts
?? scripts/utils/ollamaChat.positional-live-experiment.test.ts
?? scripts/utils/ollamaChat.positional-live-experiment.ts
?? scripts/utils/ollamaChat.positional-selection-artifact-experiment.test.ts
?? scripts/utils/ollamaChat.positional-selection-artifact-experiment.ts
?? scripts/utils/ollamaChat.positional-selection-experiment.test.ts
?? scripts/utils/ollamaChat.positional-selection-experiment.ts
?? scripts/utils/ollamaChat.project-provenance-projection.test.ts
?? scripts/utils/ollamaChat.raw-response-observer.test.ts
?? scripts/utils/ollamaChat.same-parent-rejected-identity-diagnostic.ts
?? scripts/utils/ollamaChat.selected-context-instruction-placement-experiment.ts
?? scripts/utils/ollamaChat.zero-segment-candidate-prompt.test.ts
?? scripts/validate-matilda-isolated-workflow-fixture.sh
?? scripts/verify-react-dashboard-route.sh
?? server/ellis/department-acknowledgement-provenance.test.ts
?? server/ellis/department-service-identity.test.ts
?? server/ellis/department-service-identity.ts
?? server/ellis/isolated-cryptographic-provider-registration.test.ts
?? server/ellis/isolated-cryptographic-provider-registration.ts
?? server/ellis/isolated-human-administrative-identity.test.ts
?? server/ellis/isolated-human-administrative-identity.ts
?? server/ellis/isolated-independent-human-authority.test.ts
?? server/ellis/isolated-independent-human-authority.ts
?? server/ellis/isolated-independent-provider-trust.test.ts
?? server/ellis/isolated-independent-provider-trust.ts
?? server/ellis/isolated-registration-trust-anchor.test.ts
?? server/ellis/isolated-registration-trust-anchor.ts
?? server/ellis/isolated-trusted-human-authority-contract.test.ts
?? server/ellis/isolated-trusted-human-authority-contract.ts
?? server/ellis/production-department-identity-admission.test.ts
?? server/ellis/production-department-identity-admission.ts
?? server/ellis/trusted-credential-administration.test.ts
?? server/ellis/trusted-credential-administration.ts
?? server/ellis/trusted-credential-provider-ownership.test.ts
?? server/ellis/trusted-credential-provider-ownership.ts
?? server/ellis/trusted-human-administrative-authority.test.ts
?? server/ellis/trusted-human-administrative-authority.ts
?? server/ellis/verified-acknowledgement-evidence-binding.test.ts
?? server/ellis/verified-acknowledgement-evidence-binding.ts
?? server/routes/governance-lifecycle-http-admission.test.ts
?? server/routes/governance-lifecycle-http-evidence-binding.test.ts
?? server/security/
?? snapshots/20251114-114707/db/main_backup_before_rebuild.sqlite-shm
?? snapshots/20251114-114707/db/main_backup_before_rebuild.sqlite-wal
?? snapshots/20251114-114707/db/main_backup_before_reflection_fix.sqlite-shm
?? snapshots/20251114-114707/db/main_backup_before_reflection_fix.sqlite-wal
?? snapshots/20251114-114707/db/main_backup_before_type_patch.sqlite-shm
?? snapshots/20251114-114707/db/main_backup_before_type_patch.sqlite-wal
?? snapshots/20251114-114821/db/main_backup_before_rebuild.sqlite-shm
?? snapshots/20251114-114821/db/main_backup_before_rebuild.sqlite-wal
?? snapshots/20251114-114821/db/main_backup_before_reflection_fix.sqlite-shm
?? snapshots/20251114-114821/db/main_backup_before_reflection_fix.sqlite-wal
?? snapshots/20251114-114821/db/main_backup_before_type_patch.sqlite-shm
?? snapshots/20251114-114821/db/main_backup_before_type_patch.sqlite-wal
?? trace-envelope-authoritative-field-ownership.sh
?? validate-authorized-atlas-fixture-canonical-schema-restoration.sh
?? validate-authorized-atlas-lifecycle-restoration.sh
?? validate-current-atlas-lifecycle-attempt3.sh
?? validate-existing-atlas-lifecycle-test-attempt-1.sh
?? validate-feedbackready-repair-current-worktree.sh
?? verify-and-commit-authorized-atlas-lifecycle-test.sh
?? verify-ellis-corridor-3-closure.sh
?? verify-package-semantics-corridor-closed.sh
?? verify-runtime-lifecycle-provenance-now.sh
```
