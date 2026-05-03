/*
PHASE 75 — RANKED HELPERS SMOKE TEST
*/

import { getRankedWorkflowSuggestions } from "./phase75_operator_ranked_helpers";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testRiskOrdering() {

  const results = getRankedWorkflowSuggestions({
    protectionFailure: true
  });

  assert(results.length >= 2,"Expected multiple suggestions");

  assert(
    results[0].action === "RESTORE_GOLDEN",
    "RESTORE_GOLDEN must be highest priority during RISK"
  );

}

function testCautionOrdering() {

  const results = getRankedWorkflowSuggestions({
    replayDrift: true
  });

  assert(
    results[0].action === "RUN_DIAGNOSTICS",
    "RUN_DIAGNOSTICS must be highest priority during CAUTION"
  );

}

function testSafeOrdering() {

  const results = getRankedWorkflowSuggestions({});

  assert(
    results[0].action === "CONTINUE_NARROW_WORK",
    "Progress should be highest during SAFE"
  );

}

function run(){

  testRiskOrdering();

  testCautionOrdering();

  testSafeOrdering();

  console.log("PHASE 75 RANKED HELPERS SMOKE PASS");

}

run();
