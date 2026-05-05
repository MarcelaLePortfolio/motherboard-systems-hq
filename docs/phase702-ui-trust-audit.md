# Phase 702 UI Trust & Clarity Audit

Generated: Tue May  5 10:10:50 PDT 2026

## Scope

- Verify Matilda chat behavior truthfully.
- Identify UI surfaces that may imply capabilities not currently wired.
- Do not mutate execution, persistence, database schema, SSE routes, workers, or backend behavior.

## Chat / Matilda Search Results

```
app/components/SubsystemStatusPanel.tsx:44:          fallbackPolling();
app/components/SubsystemStatusPanel.tsx:47:        fallbackPolling();
app/components/SubsystemStatusPanel.tsx:51:    const fallbackPolling = () => {
app/components/GuidancePanel.tsx:100:    const fallbackPolling = () => {
app/components/GuidancePanel.tsx:126:          fallbackPolling();
app/components/GuidancePanel.tsx:129:        fallbackPolling();
app/components/GuidancePanel.tsx.bak_phase677_pre_diff:100:    const fallbackPolling = () => {
app/components/GuidancePanel.tsx.bak_phase677_pre_diff:126:          fallbackPolling();
app/components/GuidancePanel.tsx.bak_phase677_pre_diff:129:        fallbackPolling();
app/api/guidance/route.ts:36:        source: "fallback-static",
app/api/guidance/coherence-shadow/route.ts:59:    source: 'history-or-fallback',
server/guidance/coherence-engine.mjs:60:      consistency_flag: false, // placeholder for future conflict detection
server/guidance/guidance-history-store.mjs:87:      source: "memory-fallback",
server/guidance/guidance-history-store.mjs:124:      source: "memory-fallback",
server/utils/observability/README.md:16:- aggregator.mjs → placeholder for future aggregation (inactive)
server/retry_contract.js:8:  // Ensure deterministic retry strategy
server/orchestration/router.ts:52:  // deterministic: stable order (caller controls ordering)
server/enforcement/phase44_mutation_enforcer.mjs:105:        // Allow but log deterministically.
server/enforcement/phase44_reason_codes.mjs:17:  // Internal errors (should be rare; shadow/enforce behavior still deterministic)
server/worker/phase34_claim_task_id_for_test.sql:1:-- Verification-only helper: deterministically claim a specific task id.
server/worker/phase32_mark_failure.sql:2:Phase 32 — mark failure (no retry scheduling here; keep minimal + deterministic)
server/worker/response_compiler.mjs:1:function normalizeString(value, fallback = "") {
server/worker/response_compiler.mjs:3:  return text || fallback;
server/routes/api-guidance.mjs:28:        note: "minimal_deterministic_guidance_stream"
server/routes/phase48_policy_probe.mjs:2: * Phase 48 — deterministic enforcement probe
server/routes/phase36_run_view.mjs:42:  // Phase 36.4 — Run list observability (read-only, deterministic; DB is source of truth)
server/policy/grants/resolvePolicyGrant.mjs:8: * Grant sources (deterministic):
server/policy/grants/resolvePolicyGrant.mjs:79:  // deterministic-by-input is preferred, but time is only used for expires_at comparisons;
server/policy/evaluate.legacy.mjs:28: * Pure, deterministic evaluator.
server/policy/evaluate.mjs:8: * - Apply a deterministic post-step:
server/policy/evaluate.mjs:11: *     - if grant indicates override/allow, flip result deterministically and annotate
server/policy/evaluate.mjs:148:  // Always resolve grants deterministically based on the same stable input.
server/policy/evaluate.mjs:162:  // If legacy blocks/denies and grant allows, flip deterministically.
server/policy/policy_eval.mjs:14:  // Minimal, deterministic, non-hallucinated signals:
server/policy/policy_eval.mjs:35:  // Example deterministic checks (no blocking in shadow mode):
src/cognition/proof/cognition.proof.ts:5: * Prove bounded cognition integration remains deterministic
src/cognition/proof/cognition.proof.ts:29:  "Cognition integration must remain deterministic.";
src/cognition/transport/cognitionTransport.verify.ts:29:Pure deterministic checks only.
src/cognition/transport/cognitionTransport.label.ts:14:  deterministic: true
src/cognition/transport/cognitionTransport.label.ts:36:    deterministic: true
src/cognition/transport/cognitionTransport.validate.ts:57:Return deterministic result only.
src/cognition/transport/cognitionTransport.summary.ts:15:  deterministic: true
src/cognition/transport/cognitionTransport.summary.ts:38:    deterministic: true
src/cognition/transport/cognitionTransport.replay.ts:14:  deterministic: true;
src/cognition/transport/cognitionTransport.replay.ts:27:    deterministic: true,
src/cognition/transport/cognitionTransport.dashboard.ts:13:  deterministic: true
src/cognition/transport/cognitionTransport.dashboard.ts:25:    deterministic: true
src/cognition/transport/cognitionTransport.operatorView.ts:14:  deterministic: true
src/cognition/transport/cognitionTransport.operatorView.ts:32:    deterministic: true
src/cognition/transport/consumptionRegistry/consumption_registry_enforcement.ts:74:          "Consumption registry entry is missing a deterministic consumerId.",
src/cognition/transport/consumptionRegistry/consumption_registry_enforcement.ts:109:          "Consumption registry ownership is incomplete. A deterministic ownerId is required for every consumer key.",
src/cognition/transport/consumptionRegistry/consumption_registry_enforcement_snapshot.ts:26:  generatedAt = "deterministic-proof",
src/cognition/transport/cognitionTransport.presentation.ts:19:  deterministic: true
src/cognition/transport/cognitionTransport.presentation.ts:38:    deterministic: true
src/cognition/transport/cognitionTransport.interpretation.ts:17:  deterministic: true
src/cognition/transport/cognitionTransport.interpretation.ts:32:    deterministic: true
src/cognition/transport/cognitionTransport.risk.ts:16:  deterministic: true
src/cognition/transport/cognitionTransport.risk.ts:37:    deterministic: true,
src/cognition/transport/cognitionTransport.severity.ts:16:  deterministic: true
src/cognition/transport/cognitionTransport.severity.ts:48:    deterministic: true,
src/cognition/transport/cognitionTransport.types.ts:60:Transport must remain deterministic.
src/cognition/transport/cognitionTransport.dashboardConsumption.test.ts:34:  generatedAt: "deterministic",
src/cognition/transport/cognitionTransport.dashboardConsumption.test.ts:64:console.log("phase120 dashboard consumption deterministic test passed");
src/cognition/transport/cognitionTransport.registry.ts:27:Registry is deterministic source of truth.
src/cognition/transport/cognitionTransport.governance.ts:11:  deterministic: true
src/cognition/transport/cognitionTransport.governance.ts:29:    deterministic: true,
src/cognition/span-verify/cognition.span.verify.ts:5: * Prove cognition span remains deterministic through
src/cognition/span-verify/cognition.span.verify.ts:29:  "Cognition span must remain deterministic.";
src/cognition/confidence/confidenceInvariant.ts:25:      "Operational confidence synthesis is non-deterministic for identical inputs.",
src/cognition/channel-verify/cognition.channel.verify.ts:5: * Prove cognition channel remains deterministic through
src/cognition/channel-verify/cognition.channel.verify.ts:29:  "Cognition channel must remain deterministic.";
src/cognition/verify/cognition.verify.ts:5: * Prove cognition enablement hook remains deterministic.
src/cognition/verify/cognition.verify.ts:28:  "Cognition hook must remain deterministic.";
src/cognition/link-verify/cognition.link.verify.ts:5: * Prove cognition link remains deterministic through
src/cognition/link-verify/cognition.link.verify.ts:29:  "Cognition link must remain deterministic.";
src/cognition/situationSummaryComposer.ts:65:    readonly fallbackScore: number;
src/cognition/situationSummaryComposer.ts:86:  return config.fallbackScore;
src/cognition/situationSummaryComposer.ts:104:      fallbackScore: 70,
src/cognition/situationSummaryComposer.ts:114:    fallbackScore: 70,
src/cognition/situationSummaryComposer.ts:123:    fallbackScore: 65,
src/cognition/situationSummaryComposer.ts:132:    fallbackScore: 70,
src/cognition/situationSummaryComposer.ts:143:      fallbackScore: 70,
src/cognition/contracts/cognition.contracts.ts:6: * enforce deterministic structure, and prepare invariant validation.
src/cognition/invariants/cognition.invariants.ts:6: * cannot drift into invalid or non-deterministic structures.
src/cognition/dispatch-verify/cognition.dispatch.verify.ts:5: * Prove cognition dispatch remains deterministic through
src/cognition/dispatch-verify/cognition.dispatch.verify.ts:29:  "Cognition dispatch must remain deterministic.";
src/cognition/invariants-read/cognition.read.invariants.ts:5: * Establish deterministic read invariants for cognition consumption.
src/cognition/relay-verify/cognition.relay.verify.ts:5: * Prove cognition relay remains deterministic through
src/cognition/relay-verify/cognition.relay.verify.ts:29:  "Cognition relay must remain deterministic.";
src/cognition/bridge-verify/cognition.bridge.verify.ts:5: * Prove cognition bridge remains deterministic through
src/cognition/bridge-verify/cognition.bridge.verify.ts:29:  "Cognition bridge must remain deterministic.";
src/cognition/replay/cognition.replay.proof.ts:5: * Provide deterministic replay verification to ensure identical
src/cognition/replay/cognition.replay.proof.ts:23:  deterministic: boolean;
src/cognition/replay/cognition.replay.proof.ts:36:  const deterministic =
src/cognition/replay/cognition.replay.proof.ts:44:    deterministic
src/cognition/route-verify/cognition.route.verify.ts:5: * Prove cognition routing remains deterministic through
src/cognition/route-verify/cognition.route.verify.ts:29:  "Cognition route must remain deterministic.";
src/contracts/demo/demoPathStitchingProof.ts:5: * Create a single, deterministic, non-runtime path:
src/governance_investigation/verification/replay_fixture_diagnostics.ts:5:Attach normalized deterministic diagnostics to replay fixture
src/governance_investigation/verification/replay_fixture_runner.ts:4:Adds replay boundary fixtures to deterministic proof coverage.
src/governance_investigation/verification/check-pathological-fixture-reproducibility.ts:5:Prove deterministic reproducibility of pathological fixture materialization.
src/governance_investigation/verification/check-pathological-fixture-reproducibility.ts:36:        "[replay-pathological-reproducibility] Non-deterministic fixture materialization detected at iteration:",
src/governance_investigation/verification/replay_pathological_fixtures.ts:5:Restore deterministic fixture ordering required by verification proofs.
src/governance_investigation/verification/replay_violation_codes.ts:5:Provide a deterministic diagnostic registry for replay verification proofs.
src/governance_investigation/verification/replay_violation_codes.ts:26:    description: "Replay event ordering violates deterministic sequence rules."
src/governance_investigation/verification/run-replay-pathological-proof-suite.ts:5:Provide a single deterministic verification entrypoint for pathological replay proof coverage.
src/governance_investigation/verification/run-replay-pathological-proof-suite.ts:6:Aggregates structural validity, deterministic ordering, and fixture reproducibility checks.
src/governance_investigation/verification/replay_fixture_library.ts:5:Provide deterministic fixtures for replay structure verification.
src/governance_investigation/verification/run-replay-verification-proof-suite.ts:5:Create deterministic master entrypoint for all replay verification proofs.
src/governance_investigation/verification/check-pathological-fixture-diagnostic-stability.ts:5:Ensure deterministic diagnostic ordering and stability across repeated verification passes.
src/governance_investigation/verification/replay_fixture_summary.ts:5:Provide deterministic aggregation for replay fixture validation results.
src/governance_investigation/verification/check-pathological-fixtures.ts:5:Resolve diagnostic code module shape deterministically and fail clearly when
src/governance_investigation/verification/check-pathological-fixtures.ts:45:        "[replay-pathological-check] Non-deterministic fixture ordering detected:",
src/governance_investigation/verification/check-pathological-fixtures.ts:79:    "[replay-pathological-check] PASS: deterministic ordering + valid diagnostics"
src/governance_investigation/verification/run-replay-diagnostic-stability-proof.ts:5:Add deterministic runner for diagnostic stability verification.
src/governance_investigation/verification/replay_structure_verifier.ts:6:them deterministically without requiring callers to satisfy a trusted
src/governance_traceability/governance_traceability_snapshot.ts:31:    provenance_summary: input.provenance_summary ?? "deterministic governance path",
src/governance/governance_policy_router.ts:4:Provides deterministic routing from enforcement decision
src/governance/governanceCognitionSelectorsProof.ts:37:  deterministic: true;
src/governance/governanceCognitionSelectorsProof.ts:80:    deterministic: true,
src/governance/governance_policy_router.test.ts:30:console.log("Governance policy router deterministic")
src/governance/governanceExecutionRoutingClassifier.ts:37:    deterministic: true
src/governance/governance_policy_engine.test.ts:39:console.log("Governance policy engine deterministic")
src/governance/governanceCognitionSurfaceProof.ts:30:  deterministic: true;
src/governance/governanceCognitionSurfaceProof.ts:55:  if (!surface.readonly || !surface.deterministic || !surface.operatorVisible) {
src/governance/governanceCognitionSurfaceProof.ts:67:    deterministic: true,
src/governance/governance_enforcement_evaluator.test.ts:28:console.log("Governance enforcement evaluator deterministic")
src/governance/governanceExecutionRoutingProof.ts:21:  deterministic: true;
src/governance/governanceExecutionRoutingProof.ts:44:    if (!result.deterministic) {
src/governance/governanceExecutionRoutingProof.ts:45:      throw new Error("Non-deterministic routing detected");
src/governance/governanceExecutionRoutingProof.ts:50:      deterministic: true,
src/governance/governance_signal_classifier.ts:82:    deterministic: true
src/governance/governance_signal_classifier.ts:125:            deterministic: true
src/governance/governance_signal_classifier.ts:135:            deterministic: true
src/governance/governance_signal_classifier.ts:145:            deterministic: true
src/governance/governance_signal_classifier.ts:154:        deterministic: true
src/governance/governanceCognitionIntegrationProof.ts:34:  deterministic: true;
src/governance/governanceCognitionIntegrationProof.ts:73:    deterministic: true,
src/governance/governanceOperatorAwarenessTypes.ts:41:  deterministic: true;
src/governance/governanceOperatorAwarenessTypes.ts:51:  deterministic: true;
src/governance/cognition/prove_governance_runtime_registry_export.ts:19:  readonly deterministic: true;
src/governance/cognition/prove_governance_runtime_registry_export.ts:81:    deterministic: true as const,
src/governance/cognition/prove_governance_live_registry_wiring_readiness.ts:22:  readonly deterministic: true;
src/governance/cognition/prove_governance_live_registry_wiring_readiness.ts:88:  assert(selected.readinessReasonCount >= 4, "Readiness must expose deterministic reasons.");
src/governance/cognition/prove_governance_live_registry_wiring_readiness.ts:92:    deterministic: true as const,
src/governance/cognition/select_governance_shared_registry_owner_bundle.ts:4: * Read-only deterministic owner-facing selection surface.
src/governance/cognition/select_governance_shared_registry_owner_bundle.ts:19:  readonly deterministic: true;
src/governance/cognition/select_governance_shared_registry_owner_bundle.ts:35:    deterministic: true as const
src/governance/cognition/governance_dashboard_contract_registration.ts:32:  readonly deterministic: true;
src/governance/cognition/governance_final_pre_live_registry_contract_package.ts:45:  readonly deterministic: true;
src/governance/cognition/build_governance_dashboard_consumption_view.ts:40:    deterministic: true as const
src/governance/cognition/build_governance_final_pre_live_registry_archive_record.ts:4: * Pure deterministic adapter from final delivery receipt
src/governance/cognition/build_governance_final_pre_live_registry_archive_record.ts:58:    deterministic: true as const
src/governance/cognition/build_governance_final_delivery_receipt.ts:4: * Pure deterministic adapter from pre-live registry delivery manifest
src/governance/cognition/build_governance_final_delivery_receipt.ts:57:    deterministic: true as const
src/governance/cognition/governance_authorization_gate.ts:48:  readonly deterministic: true;
src/governance/cognition/build_governance_pre_live_registry_delivery_manifest.ts:4: * Pure deterministic adapter from pre-live registry handoff envelope
src/governance/cognition/build_governance_pre_live_registry_delivery_manifest.ts:56:    deterministic: true as const
src/governance/cognition/governance_live_wiring_decision.ts:47:  readonly deterministic: true;
src/governance/cognition/build_governance_live_wiring_decision.ts:4: * Pure deterministic adapter from live registry wiring readiness
src/governance/cognition/build_governance_live_wiring_decision.ts:62:    deterministic: true as const
src/governance/cognition/build_governance_pre_live_registry_handoff_envelope.ts:4: * Pure deterministic adapter from final pre-live registry contract package
src/governance/cognition/build_governance_pre_live_registry_handoff_envelope.ts:55:    deterministic: true as const
src/governance/cognition/select_governance_final_pre_live_registry_archive_record.ts:4: * Read-only deterministic archive selection surface.
src/governance/cognition/select_governance_final_pre_live_registry_archive_record.ts:27:  readonly deterministic: true;
src/governance/cognition/select_governance_final_pre_live_registry_archive_record.ts:51:    deterministic: true as const
src/governance/cognition/prove_governance_final_pre_live_registry_summary_capsule.ts:30:  readonly deterministic: true;
src/governance/cognition/prove_governance_final_pre_live_registry_summary_capsule.ts:104:  assert(selected.capsuleReasonCount >= 4, "Capsule must expose deterministic reasons.");
src/governance/cognition/prove_governance_final_pre_live_registry_summary_capsule.ts:108:    deterministic: true as const,
src/governance/cognition/select_governance_pre_live_registry_delivery_manifest.ts:4: * Read-only deterministic delivery manifest selection surface.
src/governance/cognition/select_governance_pre_live_registry_delivery_manifest.ts:25:  readonly deterministic: true;
src/governance/cognition/select_governance_pre_live_registry_delivery_manifest.ts:47:    deterministic: true as const
src/governance/cognition/select_governance_final_pre_live_registry_summary_capsule.ts:4: * Read-only deterministic summary selection surface.
src/governance/cognition/select_governance_final_pre_live_registry_summary_capsule.ts:28:  readonly deterministic: true;
src/governance/cognition/select_governance_final_pre_live_registry_summary_capsule.ts:53:    deterministic: true as const
src/governance/cognition/governance_cognition_snapshot_contract.ts:36:  readonly deterministic: true;
src/governance/cognition/governance_pre_live_registry_delivery_manifest.ts:47:  readonly deterministic: true;
src/governance/cognition/build_governance_shared_registry_owner_bundle.ts:4: * Pure deterministic adapter from runtime-registry-facing export
src/governance/cognition/build_governance_shared_registry_owner_bundle.ts:34:    deterministic: true as const
src/governance/cognition/governance_final_pre_live_registry_summary_capsule.ts:50:  readonly deterministic: true;
src/governance/cognition/prove_governance_final_delivery_receipt.ts:28:  readonly deterministic: true;
src/governance/cognition/prove_governance_final_delivery_receipt.ts:96:  assert(selected.receiptReasonCount >= 4, "Receipt must expose deterministic reasons.");
src/governance/cognition/prove_governance_final_delivery_receipt.ts:100:    deterministic: true as const,
src/governance/cognition/select_governance_dashboard_consumption_view.ts:4: * Read-only deterministic selector surface.
src/governance/cognition/select_governance_dashboard_consumption_view.ts:14:  readonly deterministic: true;
src/governance/cognition/select_governance_dashboard_consumption_view.ts:25:    deterministic: true as const
src/governance/cognition/governance_final_pre_live_registry_archive_record.ts:49:  readonly deterministic: true;
src/governance/cognition/prove_governance_final_pre_live_registry_contract_package.ts:25:  readonly deterministic: true;
src/governance/cognition/prove_governance_final_pre_live_registry_contract_package.ts:111:  assert(selected.packageReasonCount >= 4, "Contract package must expose deterministic reasons.");
src/governance/cognition/prove_governance_final_pre_live_registry_contract_package.ts:115:    deterministic: true as const,
src/governance/cognition/prove_governance_pre_live_registry_delivery_manifest.ts:27:  readonly deterministic: true;
src/governance/cognition/prove_governance_pre_live_registry_delivery_manifest.ts:125:  assert(selected.manifestReasonCount >= 4, "Manifest must expose deterministic reasons.");
src/governance/cognition/prove_governance_pre_live_registry_delivery_manifest.ts:129:    deterministic: true as const,
src/governance/cognition/select_governance_final_pre_live_registry_contract_package.ts:4: * Read-only deterministic package selection surface.
src/governance/cognition/select_governance_final_pre_live_registry_contract_package.ts:23:  readonly deterministic: true;
src/governance/cognition/select_governance_final_pre_live_registry_contract_package.ts:43:    deterministic: true as const
src/governance/cognition/prove_governance_dashboard_consumption_view.ts:15:  readonly deterministic: true;
src/governance/cognition/prove_governance_dashboard_consumption_view.ts:48:  assert(selected.headlineStatus === "review", "Selected status must preserve deterministic precedence.");
src/governance/cognition/prove_governance_dashboard_consumption_view.ts:49:  assert(selected.headlineSeverity === "elevated", "Selected severity must preserve deterministic precedence.");
src/governance/cognition/prove_governance_dashboard_consumption_view.ts:53:    deterministic: true as const,
src/governance/cognition/governance_shared_registry_owner_bundle.ts:35:  readonly deterministic: true;
src/governance/cognition/governance_dashboard_consumption_contract.ts:34:  readonly deterministic: true;
src/governance/cognition/operationalConfidence.test.ts:29:console.log("phase 99.2 operational confidence deterministic check passed");
src/governance/cognition/select_governance_runtime_registry_export.ts:4: * Read-only deterministic registry-facing selection surface.
src/governance/cognition/select_governance_runtime_registry_export.ts:18:  readonly deterministic: true;
src/governance/cognition/select_governance_runtime_registry_export.ts:33:    deterministic: true as const
src/governance/cognition/prove_governance_authorization_gate.ts:24:  readonly deterministic: true;
src/governance/cognition/prove_governance_authorization_gate.ts:104:  assert(selected.authorizationReasonCount >= 4, "Authorization gate must expose deterministic reasons.");
src/governance/cognition/prove_governance_authorization_gate.ts:108:    deterministic: true as const,
src/governance/cognition/prove_governance_live_wiring_decision.ts:23:  readonly deterministic: true;
src/governance/cognition/prove_governance_live_wiring_decision.ts:97:  assert(selected.decisionReasonCount >= 4, "Decision must expose deterministic reasons.");
src/governance/cognition/prove_governance_live_wiring_decision.ts:101:    deterministic: true as const,
src/governance/cognition/select_governance_final_delivery_receipt.ts:4: * Read-only deterministic acknowledgement selection surface.
src/governance/cognition/select_governance_final_delivery_receipt.ts:26:  readonly deterministic: true;
src/governance/cognition/select_governance_final_delivery_receipt.ts:49:    deterministic: true as const
src/governance/cognition/build_governance_cognition_snapshot.ts:82:    deterministic: true as const
src/governance/cognition/prove_governance_cognition_snapshot.ts:14:  readonly deterministic: true;
src/governance/cognition/prove_governance_cognition_snapshot.ts:40:  assert(normalized.deterministic === true, "Normalized snapshot must remain deterministic.");
src/governance/cognition/prove_governance_cognition_snapshot.ts:44:  assert(packaged.snapshot.overallStatus === "review", "Overall status must preserve deterministic precedence.");
src/governance/cognition/prove_governance_cognition_snapshot.ts:45:  assert(packaged.snapshot.severity === "elevated", "Severity must preserve deterministic precedence.");
src/governance/cognition/prove_governance_cognition_snapshot.ts:49:    deterministic: true as const,
src/governance/cognition/prove_governance_dashboard_contract_registration.ts:16:  readonly deterministic: true;
src/governance/cognition/prove_governance_dashboard_contract_registration.ts:64:    deterministic: true as const,
src/governance/cognition/build_governance_live_registry_wiring_readiness.ts:4: * Pure deterministic adapter from shared-registry-owner-facing bundle
src/governance/cognition/build_governance_live_registry_wiring_readiness.ts:20:    "deterministic",
src/governance/cognition/build_governance_live_registry_wiring_readiness.ts:33:    ownerBundle.deterministic === true &&
src/governance/cognition/build_governance_live_registry_wiring_readiness.ts:60:    deterministic: true as const
src/governance/cognition/build_governance_authorization_gate.ts:4: * Pure deterministic adapter from explicit live wiring decision
src/governance/cognition/build_governance_authorization_gate.ts:63:    deterministic: true as const
src/governance/cognition/build_governance_final_pre_live_registry_summary_capsule.ts:4: * Pure deterministic adapter from final pre-live registry archive record
src/governance/cognition/build_governance_final_pre_live_registry_summary_capsule.ts:59:    deterministic: true as const
src/governance/cognition/governance_pre_live_registry_handoff_envelope.ts:46:  readonly deterministic: true;
src/governance/cognition/normalize_governance_shared_registry_owner_bundle.ts:4: * Defensive deterministic normalization for owner-facing export bundles.
src/governance/cognition/normalize_governance_shared_registry_owner_bundle.ts:33:          deterministic: true as const
src/governance/cognition/normalize_governance_shared_registry_owner_bundle.ts:38:        deterministic: true as const
src/governance/cognition/normalize_governance_shared_registry_owner_bundle.ts:43:      deterministic: true as const
src/governance/cognition/normalize_governance_shared_registry_owner_bundle.ts:48:    deterministic: true as const
src/governance/cognition/prove_governance_final_pre_live_registry_archive_record.ts:29:  readonly deterministic: true;
src/governance/cognition/prove_governance_final_pre_live_registry_archive_record.ts:100:  assert(selected.archiveReasonCount >= 4, "Archive record must expose deterministic reasons.");
src/governance/cognition/prove_governance_final_pre_live_registry_archive_record.ts:104:    deterministic: true as const,
src/governance/cognition/governance_live_registry_wiring_readiness.ts:41:  readonly deterministic: true;
src/governance/cognition/prove_governance_shared_registry_owner_bundle.ts:21:  readonly deterministic: true;
src/governance/cognition/prove_governance_shared_registry_owner_bundle.ts:90:    deterministic: true as const,
src/governance/cognition/package_governance_cognition_snapshot.ts:4: * Operator-safe deterministic packaging layer for dashboard-safe consumption.
src/governance/cognition/package_governance_cognition_snapshot.ts:19:  readonly deterministic: true;
src/governance/cognition/package_governance_cognition_snapshot.ts:34:    deterministic: true as const
src/governance/cognition/package_governance_cognition_snapshot.ts:43:    deterministic: true as const
src/governance/cognition/normalize_governance_runtime_registry_export.ts:4: * Defensive deterministic normalization for registry-facing export surfaces.
src/governance/cognition/normalize_governance_runtime_registry_export.ts:29:        deterministic: true as const
src/governance/cognition/normalize_governance_runtime_registry_export.ts:34:      deterministic: true as const
src/governance/cognition/normalize_governance_runtime_registry_export.ts:39:    deterministic: true as const
src/governance/cognition/select_governance_pre_live_registry_handoff_envelope.ts:4: * Read-only deterministic handoff envelope selection surface.
src/governance/cognition/select_governance_pre_live_registry_handoff_envelope.ts:24:  readonly deterministic: true;
src/governance/cognition/select_governance_pre_live_registry_handoff_envelope.ts:45:    deterministic: true as const
src/governance/cognition/select_governance_authorization_gate.ts:4: * Read-only deterministic authorization selection surface.
src/governance/cognition/select_governance_authorization_gate.ts:22:  readonly deterministic: true;
src/governance/cognition/select_governance_authorization_gate.ts:41:    deterministic: true as const
src/governance/cognition/normalize_governance_snapshot.ts:4: * Ensures deterministic structure.
src/governance/cognition/normalize_governance_snapshot.ts:19:    deterministic: true as const
src/governance/cognition/normalize_governance_dashboard_contract_registration.ts:4: * Defensive deterministic normalization for registry-facing registration.
src/governance/cognition/normalize_governance_dashboard_contract_registration.ts:25:      deterministic: true as const
src/governance/cognition/normalize_governance_dashboard_contract_registration.ts:30:    deterministic: true as const
src/governance/cognition/governance_final_delivery_receipt.ts:48:  readonly deterministic: true;
src/governance/cognition/register_governance_dashboard_contract.ts:4: * Pure deterministic registration adapter.
src/governance/cognition/register_governance_dashboard_contract.ts:30:    deterministic: true as const
src/governance/cognition/prove_governance_pre_live_registry_handoff_envelope.ts:26:  readonly deterministic: true;
src/governance/cognition/prove_governance_pre_live_registry_handoff_envelope.ts:118:  assert(selected.envelopeReasonCount >= 4, "Envelope must expose deterministic reasons.");
src/governance/cognition/prove_governance_pre_live_registry_handoff_envelope.ts:122:    deterministic: true as const,
src/governance/cognition/build_governance_final_pre_live_registry_contract_package.ts:4: * Pure deterministic adapter from authorization gate
src/governance/cognition/build_governance_final_pre_live_registry_contract_package.ts:54:    deterministic: true as const
src/governance/cognition/select_governance_live_registry_wiring_readiness.ts:4: * Read-only deterministic readiness selection surface.
src/governance/cognition/select_governance_live_registry_wiring_readiness.ts:19:  readonly deterministic: true;
src/governance/cognition/select_governance_live_registry_wiring_readiness.ts:35:    deterministic: true as const
src/governance/cognition/governance_runtime_registry_export.ts:35:  readonly deterministic: true;
src/governance/cognition/select_governance_live_wiring_decision.ts:4: * Read-only deterministic decision selection surface.
src/governance/cognition/select_governance_live_wiring_decision.ts:21:  readonly deterministic: true;
src/governance/cognition/select_governance_live_wiring_decision.ts:39:    deterministic: true as const
src/governance/cognition/build_governance_runtime_registry_export.ts:4: * Pure deterministic adapter from governance dashboard contract registration
src/governance/cognition/build_governance_runtime_registry_export.ts:33:    deterministic: true as const
src/governance/governance_explanation_builder.test.ts:52:console.log("Governance explanation builder deterministic")
src/governance/governanceCognitionSurfaceBuilder.ts:74:    deterministic: true
src/governance/governanceOutcomeSurfaceTypes.ts:36:  deterministic: true;
src/governance/governanceOutcomeSurfaceBuilder.ts:45:    deterministic: true,
src/governance/governance_explanation_builder.ts:4:Builds deterministic human-readable explanations from
src/governance/governance_decision_pipeline.ts:4:Creates a deterministic pipeline connecting:
src/governance/governance_advisory_normalizer.test.ts:36:  it("orders by severity deterministically", () => {
src/governance/governanceOperatorAwarenessProof.ts:29:  deterministic: true;
src/governance/governanceOperatorAwarenessProof.ts:52:    if (!signal.readonly || !signal.deterministic || !signal.operatorVisible) {
src/governance/governanceOperatorAwarenessProof.ts:60:  if (!summary.readonly || !summary.deterministic) {
src/governance/governanceOperatorAwarenessProof.ts:67:    deterministic: true,
src/governance/governanceCognitionIntegrationHooks.ts:35:  deterministic: true;
src/governance/governanceCognitionIntegrationHooks.ts:52:    deterministic: true
src/governance/governanceOutcomeSurfaceProof.ts:23:  deterministic: true;
src/governance/governanceOutcomeSurfaceProof.ts:46:    if (!surface.readonly || !surface.deterministic) {
src/governance/governanceOutcomeSurfaceProof.ts:53:      deterministic: true,
src/governance/governance_advisory_normalizer.ts:5:Normalize governance advisory signals for deterministic ordering,
src/governance/governance_advisory_contract.ts:45:  Unique deterministic id
src/governance/governance_advisory_contract.ts:118:Pure deterministic helper
src/governance/governance_fixture_corpus.ts:3:Canonical deterministic governance signal fixtures
src/governance/governanceOperatorAwarenessSummary.ts:46:    deterministic: true
src/governance/governanceExecutionRouting.ts:29:  deterministic: true;
src/governance/governanceExecutionRouting.ts:51:        deterministic: true
src/governance/governanceExecutionRouting.ts:59:        deterministic: true
src/governance/governanceExecutionRouting.ts:67:        deterministic: true
src/governance/governanceExecutionRouting.ts:75:        deterministic: true
src/governance/governanceExecutionRouting.ts:83:        deterministic: true
src/governance/governance_enforcement_result.ts:4:Defines the deterministic output contract for governance enforcement.
src/governance/governanceOperatorAwarenessBuilder.ts:44:    deterministic: true,
src/governance/governance_advisory_report_builder.ts:7:Pure deterministic builder for GovernanceAdvisoryReport.
src/governance/governance_decision_pipeline.test.ts:35:console.log("Governance decision pipeline deterministic")
src/governance/governance_advisory_stability_sentinel.test.ts:6:  it("governance advisory remains deterministic", () => {
src/governance/governance_audit_log.test.ts:34:console.log("Governance audit log deterministic")
src/governance/governance_advisory_pipeline.ts:3:End-to-end deterministic advisory assembly
src/governance/governance_audit_log.ts:4:Creates a deterministic governance audit record layer.
src/governance/governance_pipeline_invariants.test.ts:16:console.log("Governance invariants deterministic")
src/governance/governanceCognitionSurfaceTypes.ts:33:  deterministic: true;
src/governance/governanceExecutionRoutingTypes.ts:3: * Separates routing result structure for future deterministic extensions.
src/governance/governanceExecutionRoutingTypes.ts:21:  deterministic: true;
src/governance/governance_signal_classifier.test.ts:5:Verify deterministic behavior of the first governance module
src/governance/governance_signal_classifier.test.ts:59:  assert.equal(riskClassification.deterministic, true);
src/governance_reporting/governance_reporting_builder.ts:30:    input.provenance_summary ?? "deterministic governance path";
src/telemetry/queueThroughputHarness.ts:5:Local deterministic verification only.
src/governance_digest/governance_digest_builder.ts:31:    input.provenance_summary ?? "deterministic governance path";
```

## KPI / Ambiguous State Search Results

```
app/demo-runtime/page.tsx:83:  const [loading, setLoading] = useState(false);
app/demo-runtime/page.tsx:104:    setLoading(true);
app/demo-runtime/page.tsx:132:      setLoading(false);
app/components/SubsystemStatusPanel.tsx:27:  const [loading, setLoading] = useState(true);
app/components/SubsystemStatusPanel.tsx:39:          setLoading(false);
app/components/SubsystemStatusPanel.tsx:58:          setLoading(false);
app/components/SubsystemStatusPanel.tsx:74:  if (loading) return <div style={{ padding: '12px' }}>Loading subsystem status...</div>;
app/components/ExecutionInspector.tsx:62:              {guidance.classification || 'unknown'}
app/components/GuidancePanel.tsx:16:  const [loading, setLoading] = useState(true);
app/components/GuidancePanel.tsx:28:      setLoading(false);
app/components/GuidancePanel.tsx:118:            setLoading(false);
app/components/GuidancePanel.tsx:141:  if (loading) return <div style={{ padding: '12px' }}>Loading guidance...</div>;
app/components/GuidancePanel.tsx:231:      : 'unknown-time';
app/components/GuidancePanel.tsx:265:            <span style={{ fontWeight: 700 }}>{signal?.subsystem || 'unknown'}:</span>{' '}
app/components/GuidancePanel.tsx:398:              <div>Source: {coherenceData.source || 'unknown'}</div>
app/components/GuidancePanel.tsx:408:                <div>Persistence source: {coherenceData.persistence?.source || 'unknown'}</div>
app/components/GuidancePanel.tsx.bak_phase677_pre_diff:16:  const [loading, setLoading] = useState(true);
app/components/GuidancePanel.tsx.bak_phase677_pre_diff:28:      setLoading(false);
app/components/GuidancePanel.tsx.bak_phase677_pre_diff:118:            setLoading(false);
app/components/GuidancePanel.tsx.bak_phase677_pre_diff:141:  if (loading) return <div style={{ padding: '12px' }}>Loading guidance...</div>;
app/components/GuidancePanel.tsx.bak_phase677_pre_diff:321:              <div>Source: {coherenceData.source || 'unknown'}</div>
app/api/guidance/route.ts:37:        error: err?.message ?? "unknown_error",
server/taskContract.mjs:32:  // tolerate empty/unknown -> queued
server/guidance/coherence-engine.mjs:7:  const subsystem = evt.subsystem || 'unknown';
server/artifacts.mjs:68:    source: artifact?.source || "unknown",
server/orchestration/operator-commands.ts:90:  return { ok: false, error: "unknown command" };
server/orchestration/router.ts:3:export type AgentId = "matilda" | "cade" | "effie" | "atlas" | "unknown";
server/orchestration/task-state-machine.ts:22:  payload: unknown;
server/orchestration/task-state-machine.ts:97:      return { ok: false, error: "unknown event", task: t };
server/orchestration/policy-pipeline.ts:28:        throw new Error(`unknown decision ${(d as any).kind}`);
server/orchestration/policy.ts:2:  | { type: "event.ingested"; ts: number; source: string; payload?: unknown }
server/orchestration/deps.ts:17: * - Missing dependency IDs are treated as blocking (unknown).
server/api/tasks-mutations/delegate-taskspec.mjs:81:      const __id = (task?.action_id ?? task?.task_id ?? task_id ?? actionId ?? action_name ?? "<unknown>");
server/api/guidance.original.mjs:17:        id: "atlas-optional-offline",
server/api/guidance.original.mjs:19:        message: "Atlas is optional and may be offline without blocking execution.",
server/routes/subsystem-status.js:18:      status: 'unknown',
server/routes/operator-guidance.mjs:104:      status: "degraded",
server/routes/operator-guidance.mjs:204:        detail: error?.message || "unknown_error",
server/routes/operator-guidance.mjs:295:          detail: error?.message || "unknown_error",
server/routes/api-tasks-mutations.mjs:51:      error: b.error ?? b.err ?? "unknown_error",
server/routes/guidance-sse.js:20:      status: 'unknown',
server/routes/guidance.js:20:      status: 'unknown',
server/routes/subsystem-sse.js:21:      status: 'unknown',
server/execution_guidance_router.mjs:32:    return 'unknown';
server/execution_guidance_router.mjs:63:  return 'unknown';
server/orchestrator/phase18_store.mjs:29:      const prev = state.agents.get(agentId) || { lastSeenAt: null, status: "unknown", meta: {} };
server/policy/policy_grants.ts:12:  metadata: unknown;
server/policy/policy_grants.ts:35:  let lastErr: unknown = null;
server/policy/policy_audit_shape.mjs:25:    confidence: input?.decision?.confidence ?? "unknown",
server/policy/policy_audit_shape.mjs:33:    emitted_by: pickEnv(env, ["WORKER_ID", "WORKER_NAME", "HOSTNAME"]) ?? "unknown",
server/policy/__tests__/evaluate.test.mjs:7:  defaults: { unknown_action_tier: 'B', unknown_action_decision: 'deny' },
server/policy/__tests__/evaluate.test.mjs:16:  const r = evaluatePolicy({ action_id: 'unknown.action', context: {} }, { policy });
server/policy/__tests__/load_default_policy.test.mjs:12:  const r = evaluatePolicy({ action_id: 'unknown.action', context: {} }, { policy });
server/policy/evaluate.legacy.mjs:48:  const defaultTier = defaults.unknown_action_tier || 'B';
server/policy/evaluate.legacy.mjs:49:  const defaultDecision = defaults.unknown_action_decision || 'deny';
server/policy/evaluate.legacy.mjs:88:    trace.reasons.push(`matched:${r.id || 'unknown'}`);
server/policy/evaluate.mjs:167:  // If legacyAllowed is unknown, do not flip (safe default) but still allow downstream inspection.
server/policy/policy_eval.mjs:27:  // Keep conservative: default allow with unknown confidence.
server/policy/policy_eval.mjs:32:    confidence: "unknown",
server/policy/policy_eval.mjs:37:    decision.reasons.push({ code: "unknown_action_tier", value: String(signals.action_tier) });
server/policy/grants.mjs:100:    return { ok: true, grant: g, reason: `matched:${id || 'unknown'}` };
src/cognition/index.smoke.ts:40:    inputs.governanceCognitionState === "unknown",
src/cognition/transport/cognitionTransport.label.ts:22:      return "Transport degraded"
src/cognition/transport/transportReplaySafety.assert.ts:1:export function assertTransportReplaySafety(snapshot: unknown): boolean {
src/cognition/transport/CognitionTransportDiagnostics.builder.ts:9:  snapshot?: unknown
src/cognition/transport/cognitionTransport.dashboardConsumption.ts:9:  payload: Readonly<Record<string, unknown>>
src/cognition/situationSummaryComposer.ts:5:  | "degraded"
src/cognition/situationSummaryComposer.ts:6:  | "unknown";
src/cognition/situationSummaryComposer.ts:11:  | "unknown";
src/cognition/situationSummaryComposer.ts:16:  | "unknown";
src/cognition/situationSummaryComposer.ts:21:  | "unknown";
src/cognition/situationSummaryComposer.ts:27:  | "unknown";
src/cognition/situationSummaryComposer.ts:32:  | "unknown";
src/cognition/situationSummaryComposer.ts:61:    readonly unknown?: readonly string[];
src/cognition/situationSummaryComposer.ts:64:    readonly unknownScore: number;
src/cognition/situationSummaryComposer.ts:71:    return config.unknownScore;
src/cognition/situationSummaryComposer.ts:74:  if ((config.unknown ?? ["unknown"]).some((token) => normalized.includes(token))) {
src/cognition/situationSummaryComposer.ts:75:    return config.unknownScore;
src/cognition/situationSummaryComposer.ts:100:      negative: ["degraded", "misaligned", "invalid", "failing", "risk", "critical"],
src/cognition/situationSummaryComposer.ts:103:      unknownScore: 50,
src/cognition/situationSummaryComposer.ts:110:    negative: ["degraded", "unstable", "critical", "failing"],
src/cognition/situationSummaryComposer.ts:113:    unknownScore: 50,
src/cognition/situationSummaryComposer.ts:122:    unknownScore: 50,
src/cognition/situationSummaryComposer.ts:128:    negative: ["incomplete", "degraded", "inconsistent", "fragmented"],
src/cognition/situationSummaryComposer.ts:131:    unknownScore: 50,
src/cognition/situationSummaryComposer.ts:139:      negative: ["incoherent", "conflicted", "degraded", "fragmented"],
src/cognition/situationSummaryComposer.ts:142:      unknownScore: 50,
src/cognition/situationSummaryComposer.ts:173:  return state ?? "unknown";
src/cognition/situationSummaryComposer.ts:179:  return state ?? "unknown";
src/cognition/situationSummaryComposer.ts:185:  return state ?? "unknown";
src/cognition/situationSummaryComposer.ts:191:  return state ?? "unknown";
src/cognition/situationSummaryComposer.ts:197:  return state ?? "unknown";
src/cognition/situationSummaryComposer.ts:203:  return state ?? "unknown";
src/cognition/situationSummaryComposer.ts:208:  if (state === "degraded") return "SYSTEM DEGRADED";
src/cognition/operatorGuidance.smoke.ts:19:function assert(condition: unknown, message: string): void {
src/cognition/operatorGuidance.smoke.ts:45:    name: "degraded_throughput",
src/cognition/operatorGuidance.smoke.ts:50:        status: "degraded",
src/cognition/operatorGuidance.smoke.ts:77:    name: "unknown_signal_quality",
src/cognition/operatorGuidance.smoke.ts:82:        status: "unknown",
src/cognition/operatorGuidance.smoke.ts:93:    name: "conflicting_healthy_and_degraded",
src/cognition/operatorGuidance.smoke.ts:106:        status: "degraded",
src/cognition/operatorGuidance.live.ts:25:    status: "degraded",
src/cognition/operatorGuidance.live.ts:41:    status: "unknown",
src/cognition/situationSummaryInputAdapter.ts:17:  if (value === "degraded") return "degraded";
src/cognition/situationSummaryInputAdapter.ts:18:  return "unknown";
src/cognition/situationSummaryInputAdapter.ts:26:  return "unknown";
src/cognition/situationSummaryInputAdapter.ts:34:  return "unknown";
src/cognition/situationSummaryInputAdapter.ts:42:  return "unknown";
src/cognition/situationSummaryInputAdapter.ts:51:  return "unknown";
src/cognition/situationSummaryInputAdapter.ts:54:function isBoolean(value: unknown): value is boolean {
src/cognition/situationSummaryInputAdapter.ts:58:function isString(value: unknown): value is string {
src/cognition/situationSummaryInputAdapter.ts:62:function isFiniteNumber(value: unknown): value is number {
src/cognition/situationSummaryInputAdapter.ts:66:function isRecord(value: unknown): value is Record<string, unknown> {
src/cognition/situationSummaryInputAdapter.ts:71:  value: unknown
src/cognition/situationSummaryInputAdapter.ts:83:  value: unknown
src/cognition/situationSummaryInputAdapter.ts:95:  value: unknown
src/cognition/situationSummaryInputAdapter.ts:104:  value: unknown
src/cognition/situationSummaryInputAdapter.ts:112:  value: unknown
src/cognition/situationSummaryInputAdapter.ts:123:  value: unknown
src/cognition/situationSummaryInputAdapter.ts:136:  value: unknown
src/cognition/situationSummaryInputAdapter.ts:158:  if (!awareness) return "unknown";
src/cognition/operatorGuidanceMapping.ts:11:export type GuidanceSignalStatus = "healthy" | "degraded" | "stalled" | "unknown";
src/cognition/operatorGuidanceMapping.ts:41:    case "degraded":
src/cognition/operatorGuidanceMapping.ts:45:    case "unknown":
src/cognition/operatorGuidanceMapping.ts:54:    case "degraded":
src/cognition/operatorGuidanceMapping.ts:58:    case "unknown":
src/cognition/operatorGuidanceMapping.ts:69:    case "degraded":
src/cognition/operatorGuidanceMapping.ts:73:    case "unknown":
src/cognition/operatorGuidanceMapping.ts:125:    id: "system-health-degraded",
src/cognition/operatorGuidanceMapping.ts:128:      signal.domain === "system_health" && signal.status === "degraded",
src/cognition/operatorGuidanceMapping.ts:161:    id: "throughput-degraded",
src/cognition/operatorGuidanceMapping.ts:164:      signal.domain === "throughput" && signal.status === "degraded",
src/cognition/operatorGuidanceMapping.ts:185:    id: "latency-degraded",
src/cognition/operatorGuidanceMapping.ts:188:      signal.domain === "latency" && signal.status === "degraded",
src/cognition/operatorGuidanceMapping.ts:209:    id: "task-lifecycle-degraded",
src/cognition/operatorGuidanceMapping.ts:212:      signal.domain === "task_lifecycle" && signal.status === "degraded",
src/cognition/operatorGuidanceMapping.ts:233:    id: "signal-quality-unknown",
src/cognition/operatorGuidanceMapping.ts:236:      signal.domain === "signal_quality" && signal.status === "unknown",
src/cognition/operatorGuidanceMapping.ts:247:    id: "operator-awareness-unknown",
src/cognition/operatorGuidanceMapping.ts:250:      signal.domain === "operator_awareness" && signal.status === "unknown",
src/cognition/governanceAwarenessGuards.smoke.ts:47:const INVALID_GOVERNANCE_AWARENESS_SURFACE: unknown = {
src/cognition/operatorGuidance.ts:67:export type CriticalGuidance = OperatorGuidanceBase & {
src/cognition/operatorGuidance.ts:75:  | CriticalGuidance;
src/cognition/getSituationSummary.degraded.smoke.ts:11:    stability: "degraded",
src/cognition/getSituationSummarySnapshot.smoke.ts:32:    snapshot.summary.governanceCognitionState === "unknown",
src/cognition/operatorGuidanceConfidence.ts:35:  const degraded = signals.filter(s => s.status === "degraded").length;
src/cognition/operatorGuidanceConfidence.ts:37:  const unknown = signals.filter(s => s.status === "unknown").length;
src/cognition/operatorGuidanceConfidence.ts:41:    healthy > 0 && (degraded > 0 || stalled > 0);
src/cognition/operatorGuidanceConfidence.ts:52:  if (degraded > 0) {
src/cognition/operatorGuidanceConfidence.ts:61:  if (unknown > 0) {
src/contracts/__fixtures__/governanceExecutionBridgeAssembly.fixture.ts:27:    confidence: "unknown",
src/contracts/__fixtures__/governanceExecutionBridgeContract.fixture.ts:31:      confidence: "unknown",
src/contracts/execution/governedExecutionProof.ts:32:    emitted_events: unknown[];
src/contracts/governanceExecutionBridgeContract.ts:15:  notes: unknown;
src/contracts/governanceExecutionBridgeContract.ts:16:  source: unknown;
src/contracts/governanceExecutionBridgeContract.ts:17:  trace_id: unknown;
src/contracts/governanceExecutionBridgeContract.ts:18:  error: unknown;
src/contracts/governanceExecutionBridgeContract.ts:19:  meta: unknown;
src/contracts/governanceExecutionBridgeContract.ts:28:  meta?: unknown;
src/contracts/governanceExecutionBridgeContract.ts:68:  emitted_events: unknown[];
src/governance_investigation/governance_playback_navigation_assembly.ts:21:        policy_id: "unknown",
src/governance_investigation/governance_playback_navigation_assembly.ts:32:        policy_id: "unknown",
src/governance_investigation/governance_playback_navigation_assembly.ts:37:          policy_id: "unknown",
src/governance_investigation/verification/replay_pathological_fixtures.ts:46:    id: "unknown-event-type",
src/governance_investigation/verification/replay_pathological_fixtures.ts:48:    eventSequence: ["task.created", "task.unknown"],
src/governance_investigation/verification/replay_violation_codes.ts:38:    description: "Replay contains an unknown event type."
src/governance_investigation/verification/check-pathological-fixtures.ts:17:type ViolationCodeMap = Record<string, unknown>;
src/governance_investigation/verification/check-pathological-fixtures.ts:20:  const candidates: unknown[] = [
src/governance_investigation/verification/check-pathological-fixtures.ts:21:    (replayViolationModule as { REPLAY_VIOLATION_CODES?: unknown }).REPLAY_VIOLATION_CODES,
src/governance_investigation/verification/check-pathological-fixtures.ts:22:    (replayViolationModule as { default?: unknown }).default,
src/governance_investigation/verification/replay_structure_verifier.ts:5:Accept unknown replay payloads at the verifier boundary and validate
src/governance_investigation/verification/replay_structure_verifier.ts:34:function isObjectRecord(value: unknown): value is Record<string, unknown> {
src/governance_investigation/verification/replay_structure_verifier.ts:38:function isNonEmptyString(value: unknown): value is string {
src/governance_investigation/verification/replay_structure_verifier.ts:42:function isPositiveInteger(value: unknown): value is number {
src/governance_investigation/verification/replay_structure_verifier.ts:46:function isStrictIsoTimestamp(value: unknown): value is string {
src/governance_investigation/verification/replay_structure_verifier.ts:61:  replay: unknown
src/governance_visibility/governance_visibility_snapshot.ts:12:  explanation?: unknown;
src/governance_visibility/governance_visibility_snapshot.ts:13:  audit?: unknown;
src/governance_traceability/governance_traceability_snapshot.ts:13:  explanation?: unknown;
src/governance_traceability/governance_traceability_snapshot.ts:14:  audit?: unknown;
src/governance/governance_signal_explanation_registry.ts:30:          s.type || "unknown",
src/governance/governance_signal_explanation_registry.ts:33:          s.level || "unknown",
src/governance/governanceCognitionSelectorsProof.ts:29:  selectGovernanceCognitionCriticalSignalCount
src/governance/governanceCognitionSelectorsProof.ts:66:    selectGovernanceCognitionCriticalSignalCount(surface);
src/governance/governance_policy_engine.test.ts:37:assert(critical.decision === "block", "Critical policy must block")
src/governance/governance_advisory_contract.test.ts:51:        reasoning: "Critical severity must dominate report severity.",
src/governance/governance_enforcement_evaluator.test.ts:26:assert(critical.decision === "block", "Critical should block")
src/governance/governance_signal_classifier.ts:62:    payload?: Record<string, unknown>
src/governance/governance_signal_classifier.ts:163:        signal_id: signal?.signal_id ?? "unknown-signal-id",
src/governance/governance_signal_classifier.ts:164:        signal_type: signal?.signal_type ?? "unknown-signal-type",
src/governance/cognition/prove_governance_runtime_registry_export.ts:28:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_live_registry_wiring_readiness.ts:34:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_final_pre_live_registry_summary_capsule.ts:51:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_final_delivery_receipt.ts:47:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_final_pre_live_registry_contract_package.ts:41:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_pre_live_registry_delivery_manifest.ts:45:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_dashboard_consumption_view.ts:23:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_authorization_gate.ts:39:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_live_wiring_decision.ts:37:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_cognition_snapshot.ts:22:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_dashboard_contract_registration.ts:24:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_final_pre_live_registry_archive_record.ts:49:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_shared_registry_owner_bundle.ts:31:function assert(condition: unknown, message: string): asserts condition {
src/governance/cognition/prove_governance_pre_live_registry_handoff_envelope.ts:43:function assert(condition: unknown, message: string): asserts condition {
src/governance/governance_explanation_builder.test.ts:42:  "Critical governance condition detected."
src/governance/governance_advisory_consistency_guard.ts:16:  const hasCritical =
src/governance/governance_advisory_consistency_guard.ts:22:  if(hasCritical){
src/governance/governanceCognitionIntegrationHooks.ts:22:  selectGovernanceCognitionCriticalSignalCount,
src/governance/governanceCognitionIntegrationHooks.ts:31:  getCriticalSignalCount: () => number;
src/governance/governanceCognitionIntegrationHooks.ts:45:    getCriticalSignalCount: () =>
src/governance/governanceCognitionIntegrationHooks.ts:46:      selectGovernanceCognitionCriticalSignalCount(surface),
src/governance/governanceCognitionSelectors.ts:48:export function selectGovernanceCognitionCriticalSignalCount(
src/governance/governance_advisory_operator_view.ts:26:      headline: "Critical governance signals require operator review"
src/governance/governance_signal_classifier.test.ts:69:  const unknownClassification = classifyGovernanceSignal(missingFieldSignal);
src/governance/governance_signal_classifier.test.ts:70:  assert.equal(unknownClassification.classification, "UNKNOWN");
src/governance/governance_signal_classifier.test.ts:71:  assert.equal(unknownClassification.reason, "MISSING_REQUIRED_FIELDS");
src/governance/governance_policy_registry.ts:48:    name: "Critical Block Policy",
```

## Phase 702 Initial Finding

This audit is intentionally read-only. It establishes the first Phase 702 checkpoint before UI trust labels or clarity patches are applied.

## Next Patch Target

Use this report to patch only UI truth-alignment surfaces:

1. Matilda chat status labeling.
2. KPI placeholder replacement.
3. Health status explanation.
4. Agent/subsystem reasoning text.
