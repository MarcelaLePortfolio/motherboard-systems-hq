/*
PHASE 76 — PLAYBOOK SELECTION INTEGRATION SMOKE
Verifies deterministic integrated playbook selection.
*/

import { getIntegratedPlaybookSelection } from "./phase76_operator_playbook_selection";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testRecoveryPlaybookIntegration() {
  const result = getIntegratedPlaybookSelection({
    replayDrift: true
  });

  assert(
    result.playbookName === "RECOVERY_PLAYBOOK",
    "Expected RECOVERY_PLAYBOOK for replay drift"
  );

  assert(
    result.rankedSteps.length >= 4,
    "Expected full recovery playbook steps"
  );

  assert(
    result.rankedSteps[0]?.step === "RUN_DIAGNOSTICS",
    "Expected RUN_DIAGNOSTICS to rank first for replay drift"
  );
}

function testDiagnosticsPlaybookIntegration() {
  const result = getIntegratedPlaybookSelection({
    healthAnomaly: true
  });

  assert(
    result.playbookName === "DIAGNOSTICS_PLAYBOOK",
    "Expected DIAGNOSTICS_PLAYBOOK for health anomaly"
  );

  assert(
    result.rankedSteps.some(step => step.step === "VERIFY_HEALTH"),
    "Expected VERIFY_HEALTH in diagnostics playbook"
  );
}

function testProgressPlaybookIntegration() {
  const result = getIntegratedPlaybookSelection({});

  assert(
    result.playbookName === "PROGRESS_PLAYBOOK",
    "Expected PROGRESS_PLAYBOOK for safe state"
  );

  assert(
    result.rankedSteps[0]?.step === "CONTINUE_NARROW_WORK",
    "Expected CONTINUE_NARROW_WORK to rank first for safe state"
  );
}

function run() {
  testRecoveryPlaybookIntegration();
  testDiagnosticsPlaybookIntegration();
  testProgressPlaybookIntegration();

  console.log("PHASE 76 PLAYBOOK SELECTION SMOKE PASS");
}

run();
