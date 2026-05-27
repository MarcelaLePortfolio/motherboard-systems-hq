/*
PHASE 77 — ADAPTATION GUARDRAILS SMOKE
Verifies deterministic safety guardrail enforcement.
*/

import { applyAdaptationGuardrails } from "./phase77_adaptation_guardrails";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testHighSeverityEnforcesRecoveryBeforeProgress() {
  const result = applyAdaptationGuardrails({
    severity: "HIGH",
    orderedSteps: [
      "CONTINUE_NARROW_WORK",
      "VERIFY_HEALTH"
    ]
  });

  const diagnosticsIndex = result.guardedSteps.indexOf("RUN_DIAGNOSTICS");
  const restoreIndex = result.guardedSteps.indexOf("RESTORE_GOLDEN");
  const progressIndex = result.guardedSteps.indexOf("CONTINUE_NARROW_WORK");

  assert(
    diagnosticsIndex !== -1,
    "Expected RUN_DIAGNOSTICS to be enforced during HIGH severity"
  );

  assert(
    restoreIndex !== -1,
    "Expected RESTORE_GOLDEN to be enforced during HIGH severity"
  );

  assert(
    diagnosticsIndex < restoreIndex,
    "Expected diagnostics before restore during HIGH severity"
  );

  assert(
    restoreIndex < progressIndex,
    "Expected restore before progress during HIGH severity"
  );
}

function testMediumSeverityEnforcesDiagnosticsBeforeProgress() {
  const result = applyAdaptationGuardrails({
    severity: "MEDIUM",
    orderedSteps: [
      "CONTINUE_NARROW_WORK"
    ]
  });

  const diagnosticsIndex = result.guardedSteps.indexOf("RUN_DIAGNOSTICS");
  const progressIndex = result.guardedSteps.indexOf("CONTINUE_NARROW_WORK");

  assert(
    diagnosticsIndex !== -1,
    "Expected RUN_DIAGNOSTICS to be enforced during MEDIUM severity"
  );

  assert(
    diagnosticsIndex < progressIndex,
    "Expected diagnostics before progress during MEDIUM severity"
  );
}

function testNoGuardrailsForNoneSeverity() {
  const result = applyAdaptationGuardrails({
    severity: "NONE",
    orderedSteps: [
      "CONTINUE_NARROW_WORK"
    ]
  });

  assert(
    result.guardedSteps.length === 1 &&
      result.guardedSteps[0] === "CONTINUE_NARROW_WORK",
    "Expected NONE severity to preserve safe progress ordering"
  );

  assert(
    result.appliedRules.length === 0,
    "Expected no guardrail rules for NONE severity"
  );
}

function run() {
  testHighSeverityEnforcesRecoveryBeforeProgress();
  testMediumSeverityEnforcesDiagnosticsBeforeProgress();
  testNoGuardrailsForNoneSeverity();

  console.log("PHASE 77 ADAPTATION GUARDRAILS SMOKE PASS");
}

run();
