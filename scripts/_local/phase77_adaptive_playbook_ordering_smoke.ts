/*
PHASE 77 — ADAPTIVE PLAYBOOK ORDERING SMOKE
Verifies deterministic adaptive ordering behavior.
*/

import { getAdaptivePlaybookOrdering } from "./phase77_adaptive_playbook_ordering";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testHighSeverityRecoveryOrdering() {
  const result = getAdaptivePlaybookOrdering({
    replayDrift: true
  });

  assert(
    result.playbookName === "RECOVERY_PLAYBOOK",
    "Expected RECOVERY_PLAYBOOK for replay drift"
  );

  assert(
    result.severity === "HIGH",
    "Expected HIGH severity for replay drift"
  );

  assert(
    result.orderedSteps[0] === "RUN_DIAGNOSTICS",
    "Expected RUN_DIAGNOSTICS first for high severity recovery"
  );

  assert(
    result.orderedSteps[1] === "RESTORE_GOLDEN",
    "Expected RESTORE_GOLDEN second for high severity recovery"
  );
}

function testHighSeverityDiagnosticsOrdering() {
  const result = getAdaptivePlaybookOrdering({
    healthAnomaly: true
  });

  assert(
    result.playbookName === "DIAGNOSTICS_PLAYBOOK",
    "Expected DIAGNOSTICS_PLAYBOOK for health anomaly"
  );

  assert(
    result.severity === "HIGH",
    "Expected HIGH severity for health anomaly"
  );

  assert(
    result.orderedSteps.includes("RESTORE_GOLDEN"),
    "Expected RESTORE_GOLDEN added for high severity diagnostics"
  );
}

function testSafeProgressOrdering() {
  const result = getAdaptivePlaybookOrdering({});

  assert(
    result.playbookName === "PROGRESS_PLAYBOOK",
    "Expected PROGRESS_PLAYBOOK for safe state"
  );

  assert(
    result.severity === "NONE",
    "Expected NONE severity for safe state"
  );

  assert(
    result.orderedSteps.length === 1 &&
      result.orderedSteps[0] === "CONTINUE_NARROW_WORK",
    "Expected narrow work only for safe progress"
  );
}

function run() {
  testHighSeverityRecoveryOrdering();
  testHighSeverityDiagnosticsOrdering();
  testSafeProgressOrdering();

  console.log("PHASE 77 ADAPTIVE PLAYBOOK ORDERING SMOKE PASS");
}

run();
