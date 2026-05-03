/*
PHASE 289 — GOVERNANCE SIGNAL CLASSIFIER VERIFICATION BOUNDARY

Purpose:
Verify deterministic behavior of the first governance module
without introducing runtime wiring or execution interaction.

This file must test:

- missing field handling
- risk classification
- caution classification
- safe classification
- audit record generation

No runtime integration.
No external I/O.
Pure verification only.
*/

import assert from "node:assert/strict";
import {
  classifyGovernanceSignal,
  createGovernanceAuditRecord,
  type GovernanceSignal,
} from "./governance_signal_classifier";

function runGovernanceSignalClassifierTests(): void {
  const riskSignal: GovernanceSignal = {
    signal_id: "sig-risk-1",
    signal_type: "policy_violation_warning",
    source: "policy",
    severity: "risk",
    ts: 1710000000000,
  };

  const cautionSignal: GovernanceSignal = {
    signal_id: "sig-caution-1",
    signal_type: "boundary_notice",
    source: "telemetry",
    severity: "caution",
    ts: 1710000000001,
  };

  const safeSignal: GovernanceSignal = {
    signal_id: "sig-safe-1",
    signal_type: "normal_state",
    source: "operator",
    severity: "info",
    ts: 1710000000002,
  };

  const missingFieldSignal = null;

  const riskClassification = classifyGovernanceSignal(riskSignal);
  assert.equal(riskClassification.classification, "RISK");
  assert.equal(riskClassification.reason, "RISK_SIGNAL_DETECTED");
  assert.equal(riskClassification.governance_safe, true);
  assert.equal(riskClassification.deterministic, true);

  const cautionClassification = classifyGovernanceSignal(cautionSignal);
  assert.equal(cautionClassification.classification, "CAUTION");
  assert.equal(cautionClassification.reason, "CAUTION_SIGNAL_DETECTED");

  const safeClassification = classifyGovernanceSignal(safeSignal);
  assert.equal(safeClassification.classification, "SAFE");
  assert.equal(safeClassification.reason, "SAFE_SIGNAL_DETECTED");

  const unknownClassification = classifyGovernanceSignal(missingFieldSignal);
  assert.equal(unknownClassification.classification, "UNKNOWN");
  assert.equal(unknownClassification.reason, "MISSING_REQUIRED_FIELDS");

  const auditRecord = createGovernanceAuditRecord(riskSignal, riskClassification);
  assert.equal(auditRecord.signal_id, "sig-risk-1");
  assert.equal(auditRecord.signal_type, "policy_violation_warning");
  assert.equal(auditRecord.classification, "RISK");
  assert.equal(auditRecord.reason, "RISK_SIGNAL_DETECTED");
  assert.equal(auditRecord.governance_safe, true);

  console.log("Phase 289 governance signal classifier verification passed.");
}

runGovernanceSignalClassifierTests();
