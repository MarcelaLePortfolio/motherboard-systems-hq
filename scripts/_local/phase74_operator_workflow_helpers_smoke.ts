/*
PHASE 74 — OPERATOR WORKFLOW HELPERS SMOKE TEST
Deterministic verification for workflow suggestions.
*/

import { getOperatorWorkflowSuggestions } from "./phase74_operator_workflow_helpers";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testSafeSuggestions() {
  const results = getOperatorWorkflowSuggestions({});

  assert(results.length === 1, "Expected 1 SAFE suggestion");

  assert(
    results[0]?.suggestedAction === "CONTINUE_NARROW_WORK",
    "Expected CONTINUE_NARROW_WORK for SAFE"
  );

  assert(
    results[0]?.safetyGate === "ALLOW",
    "Expected ALLOW gate for SAFE"
  );

  assert(
    results[0]?.riskLevel === "SAFE",
    "Expected SAFE risk level"
  );
}

function testCautionSuggestions() {

  const results = getOperatorWorkflowSuggestions({
    replayDrift: true
  });

  assert(
    results.length === 2,
    "Expected 2 CAUTION suggestions"
  );

  assert(
    results.some(r => r.suggestedAction === "RUN_DIAGNOSTICS"),
    "Expected RUN_DIAGNOSTICS suggestion"
  );

  assert(
    results.some(r => r.suggestedAction === "RUN_REPLAY_VERIFICATION"),
    "Expected RUN_REPLAY_VERIFICATION suggestion"
  );

  assert(
    results.every(r => r.riskLevel === "CAUTION"),
    "Expected CAUTION risk level"
  );

}

function testRiskSuggestions() {

  const results = getOperatorWorkflowSuggestions({
    protectionFailure: true
  });

  assert(
    results.length === 2,
    "Expected 2 RISK suggestions"
  );

  assert(
    results.some(r => r.suggestedAction === "RESTORE_GOLDEN"),
    "Expected RESTORE_GOLDEN suggestion"
  );

  assert(
    results.some(r => r.suggestedAction === "RUN_DIAGNOSTICS"),
    "Expected RUN_DIAGNOSTICS suggestion"
  );

  assert(
    results.every(r => r.riskLevel === "RISK"),
    "Expected RISK risk level"
  );

  assert(
    results.some(r => r.safetyGate === "ALLOW"),
    "Expected recovery path allowed"
  );

}

function run() {

  testSafeSuggestions();

  testCautionSuggestions();

  testRiskSuggestions();

  console.log("PHASE 74 WORKFLOW HELPERS SMOKE PASS");

}

run();
