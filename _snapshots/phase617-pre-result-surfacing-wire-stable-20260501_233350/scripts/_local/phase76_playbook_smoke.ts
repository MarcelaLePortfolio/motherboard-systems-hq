/*
PHASE 76 — PLAYBOOK SMOKE
Verifies deterministic playbook selection
*/

import { getOperatorPlaybook } from "./phase76_operator_playbooks";

function assert(condition: boolean, message: string){

  if(!condition){
    throw new Error(message);
  }

}

function testRecoveryPlaybook(){

  const result = getOperatorPlaybook({
    replayDrift: true
  });

  assert(
    result.name === "RECOVERY_PLAYBOOK",
    "Recovery playbook must be selected"
  );

  assert(
    result.steps[0] === "RUN_DIAGNOSTICS",
    "Diagnostics must be first recovery step"
  );

}

function testDiagnosticsPlaybook(){

  const result = getOperatorPlaybook({
    healthAnomaly: true
  });

  assert(
    result.name === "DIAGNOSTICS_PLAYBOOK",
    "Diagnostics playbook must be selected"
  );

}

function testProgressPlaybook(){

  const result = getOperatorPlaybook({});

  assert(
    result.name === "PROGRESS_PLAYBOOK",
    "Progress playbook must be default"
  );

}

function run(){

  testRecoveryPlaybook();

  testDiagnosticsPlaybook();

  testProgressPlaybook();

  console.log("PHASE 76 PLAYBOOK SMOKE PASS");

}

run();

