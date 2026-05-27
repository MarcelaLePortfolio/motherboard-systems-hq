/*
PHASE 73 — OPERATOR SAFETY GATES SMOKE TEST
Deterministic verification for advisory safety gate behavior.
*/

import { evaluateOperatorSafetyGate } from "./phase73_operator_safety_gates";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testSafeAllowsNarrowWork() {
  const result = evaluateOperatorSafetyGate({}, "CONTINUE_NARROW_WORK");

  assert(result.gate === "ALLOW", "Expected ALLOW for safe narrow work");
  assert(result.allowed === true, "Expected allowed=true for safe narrow work");
  assert(result.riskLevel === "SAFE", "Expected SAFE risk level");
}

function testCautionBlocksHighImpactWork() {
  const result = evaluateOperatorSafetyGate(
    { replayDrift: true },
    "MODIFY_PROTECTED_SURFACE"
  );

  assert(result.gate === "BLOCK", "Expected BLOCK for caution high-impact work");
  assert(result.allowed === false, "Expected allowed=false for caution high-impact work");
  assert(result.riskLevel === "CAUTION", "Expected CAUTION risk level");
}

function testCautionAllowsVerification() {
  const result = evaluateOperatorSafetyGate(
    { telemetryGap: true },
    "RUN_DIAGNOSTICS"
  );

  assert(result.gate === "ALLOW", "Expected ALLOW for caution verification action");
  assert(result.allowed === true, "Expected allowed=true for caution verification action");
  assert(result.riskLevel === "CAUTION", "Expected CAUTION risk level");
}

function testRiskBlocksForwardChange() {
  const result = evaluateOperatorSafetyGate(
    { protectionFailure: true },
    "MODIFY_REDUCER_LOGIC"
  );

  assert(result.gate === "BLOCK", "Expected BLOCK for risk forward change");
  assert(result.allowed === false, "Expected allowed=false for risk forward change");
  assert(result.riskLevel === "RISK", "Expected RISK risk level");
}

function testRiskAllowsRecovery() {
  const result = evaluateOperatorSafetyGate(
    { protectionFailure: true },
    "RESTORE_GOLDEN"
  );

  assert(result.gate === "ALLOW", "Expected ALLOW for risk recovery action");
  assert(result.allowed === true, "Expected allowed=true for risk recovery action");
  assert(result.riskLevel === "RISK", "Expected RISK risk level");
}

function run() {
  testSafeAllowsNarrowWork();
  testCautionBlocksHighImpactWork();
  testCautionAllowsVerification();
  testRiskBlocksForwardChange();
  testRiskAllowsRecovery();

  console.log("PHASE 73 SAFETY GATES SMOKE PASS");
}

run();
