# Pre-DR Worktree Capture

- Branch: `feature/support-source-references-runtime`
- HEAD: `69a11c2bcc229315b5a51131a950fd699e0d8e74`
- Remote HEAD: `69a11c2bcc229315b5a51131a950fd699e0d8e74`
- Captured UTC: `20260924T061550Z`

## DR Boundary

Committed recovery checkpoint is aligned locally and remotely.

The worktree is intentionally dirty with unrelated local modifications, scripts, backups, diagnostics, and historical artifacts.

No reset, stash, clean, deletion, or broad staging operation is authorized by this checkpoint.

DR must preserve the current filesystem state in addition to committed Git history.

## Git Status

```text
 M .DS_Store
 M client/vite.config.ts
 M scripts/diagnose-live-selected-context-identities.ts
 M scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts
 M scripts/utils/ollamaChat.structured-evidence-object.test.ts
?? apply-isolated-execution-registry-integrity-repair.sh
?? backups/pre-clean-slate-20260901T225905Z/
?? begin-decisions-list-title-compactness-investigation.sh
?? capture-atlas-lifecycle-validation-result.sh
?? classify-execution-registry-transition-integrity.sh
?? commit-authorized-atlas-lifecycle-test-restoration.sh
?? commit-pending-validation-eligibility-repair.sh
?? commit-push-atlas-historical-adapter.sh
?? db/main.db.pre-dogfood-cleanup-20260914_140324.bak
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
?? docs/checkpoints/PARENT_DEVELOPMENT_SEQUENCE_RESUMPTION.md
?? docs/checkpoints/PRE_DR_WORKTREE_CAPTURE_20260924T061550Z.md
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
?? inspect-current-vs-historical-validation-operator-adapter.sh
?? inspect-decisions-list-compact-title-after-attempt-2-pattern-miss.sh
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
?? repair-validation-route-loader-test-seam.sh
?? restore-bounded-atlas-lifecycle-validation.sh
?? retry-authorized-atlas-lifecycle-test-attempt-3.sh
?? revalidate-package-semantics-live-seed.sh
?? revalidate-package-semantics-live-seed.ts
?? revert-atlas-lifecycle-test-after-attempt3.sh
?? review-point-4-investigation-output.sh
?? run-pre-dr-capture.sh
?? scripts/_local/repair-corridor-3-option-a-attempt-2.sh
?? scripts/classify-corridor-6-execution-field-authority-status.sh
?? scripts/classify-corridor-6-minimum-execution-approval-transition-unit.sh
?? scripts/implement-corridor-3-existing-commit-push-entry-point.sh
?? scripts/implement-corridor-6-third-runtime-hypothesis.sh
?? scripts/inspect-corridor-2-current-durable-authorization-contract.sh
?? scripts/inspect-corridor-6-approval-transition-implementation-boundaries.sh
?? scripts/inspect-corridor-6-authoritative-execution-field-sources-focused.sh
?? scripts/inspect-corridor-6-dedicated-route-binding-boundaries.sh
?? scripts/inspect-corridor-6-exact-approval-persistence-insertion-boundary.sh
?? scripts/inspect-corridor-6-full-envelope-reconstruction-source.sh
?? scripts/inspect-corridor-6-package-to-execution-authority-mapping.sh
?? scripts/inspect-corridor-6-unexpected-head.sh
?? scripts/investigate-corridor-6-durable-execution-envelope-authority-sources.sh
?? scripts/investigate-corridor-6-self-improvement-execution-activation-closure.sh
?? scripts/reconcile-corridor-2-authorization-closure-history.sh
?? scripts/reconcile-corridor-6-after-corridor-2-authority-correction.sh
?? scripts/reconcile-corridor-6-existing-execution-approval-transition.sh
?? scripts/repair-corridor-6-route-mount-checkpoint-verification.sh
?? scripts/repair-corridor-6-third-hypothesis-equivalence-check.sh
?? scripts/repair-living-draft-success-criteria-schema-entry.sh
?? scripts/repair-reconciled-success-criteria-fixture.sh
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
?? trace-envelope-authoritative-field-ownership.sh
?? validate-authorized-atlas-fixture-canonical-schema-restoration.sh
?? validate-authorized-atlas-lifecycle-restoration.sh
?? validate-current-atlas-lifecycle-attempt3.sh
?? validate-existing-atlas-lifecycle-test-attempt-1.sh
?? validate-feedbackready-repair-current-worktree.sh
?? verify-and-commit-authorized-atlas-lifecycle-test.sh
?? verify-package-semantics-corridor-closed.sh
```
