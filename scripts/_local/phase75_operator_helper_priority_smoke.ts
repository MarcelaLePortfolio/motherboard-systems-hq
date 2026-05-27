/*
PHASE 75 — PRIORITY MODEL SMOKE TEST
*/

import { scoreHelperAction } from "./phase75_operator_helper_priority";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testRiskPrioritizesRecovery() {

  const restore = scoreHelperAction("RESTORE_GOLDEN","RISK");
  const diagnostics = scoreHelperAction("RUN_DIAGNOSTICS","RISK");

  assert(
    restore.score > diagnostics.score,
    "RESTORE_GOLDEN should outrank diagnostics during RISK"
  );

}

function testCautionPrioritizesDiagnostics() {

  const diagnostics = scoreHelperAction("RUN_DIAGNOSTICS","CAUTION");
  const replay = scoreHelperAction("RUN_REPLAY_VERIFICATION","CAUTION");

  assert(
    diagnostics.score > replay.score,
    "RUN_DIAGNOSTICS should outrank replay during CAUTION"
  );

}

function testSafePrioritizesProgress() {

  const progress = scoreHelperAction("CONTINUE_NARROW_WORK","SAFE");

  assert(
    progress.score >= 70,
    "SAFE progress should receive boost"
  );

}

function run() {

  testRiskPrioritizesRecovery();

  testCautionPrioritizesDiagnostics();

  testSafePrioritizesProgress();

  console.log("PHASE 75 PRIORITY MODEL SMOKE PASS");

}

run();
