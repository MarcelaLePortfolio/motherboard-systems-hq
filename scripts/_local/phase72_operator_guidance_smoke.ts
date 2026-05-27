/*
PHASE 72 — DETERMINISTIC GUIDANCE SMOKE TEST
Verifies operator guidance produces stable outputs.
*/

import { runOperatorGuidanceCommand } from "./phase72_operator_guidance_command";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testSafeState() {
  const result = runOperatorGuidanceCommand({});

  assert(result.riskLevel === "SAFE", "Expected SAFE risk");
  assert(result.safeToContinue === true, "Expected safeToContinue true");
}

function testCautionState() {
  const result = runOperatorGuidanceCommand({
    replayDrift: true
  });

  assert(result.riskLevel === "CAUTION", "Expected CAUTION risk");
}

function testRiskState() {
  const result = runOperatorGuidanceCommand({
    protectionFailure: true
  });

  assert(result.riskLevel === "RISK", "Expected RISK risk");
  assert(result.blocking === true, "Expected blocking true");
}

function run() {
  testSafeState();
  testCautionState();
  testRiskState();

  console.log("PHASE 72 GUIDANCE SMOKE PASS");
}

run();
