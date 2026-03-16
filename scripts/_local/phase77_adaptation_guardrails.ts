/*
PHASE 77 — ADAPTATION GUARDRAILS

Enforce deterministic safety guardrails for adaptive workflow ordering.

STRICT:
READ ONLY
NO reducers
NO DB
NO telemetry mutation
NO UI mutation
NO execution authority
*/

import type { PlaybookStep } from "./phase76_operator_playbooks";

export type GuardrailInput = {
  severity: "NONE" | "LOW" | "MEDIUM" | "HIGH";
  orderedSteps: PlaybookStep[];
};

export type GuardrailResult = {
  guardedSteps: PlaybookStep[];
  appliedRules: string[];
};

function uniqueSteps(steps: PlaybookStep[]): PlaybookStep[] {
  return [...new Set(steps)];
}

function ensureStepPresent(
  steps: PlaybookStep[],
  step: PlaybookStep
): PlaybookStep[] {
  return steps.includes(step) ? steps : [...steps, step];
}

function moveStepBefore(
  steps: PlaybookStep[],
  stepToMove: PlaybookStep,
  beforeStep: PlaybookStep
): PlaybookStep[] {
  const filtered = steps.filter(
    step => step !== stepToMove
  );

  const targetIndex = filtered.indexOf(beforeStep);

  if (targetIndex === -1) {
    return [...filtered, stepToMove];
  }

  filtered.splice(targetIndex, 0, stepToMove);

  return filtered;
}

export function applyAdaptationGuardrails(
  input: GuardrailInput
): GuardrailResult {
  let guardedSteps = uniqueSteps(input.orderedSteps);
  const appliedRules: string[] = [];

  if (input.severity === "HIGH") {
    guardedSteps = ensureStepPresent(guardedSteps, "RUN_DIAGNOSTICS");
    guardedSteps = ensureStepPresent(guardedSteps, "RESTORE_GOLDEN");

    guardedSteps = moveStepBefore(
      guardedSteps,
      "RUN_DIAGNOSTICS",
      "RESTORE_GOLDEN"
    );

    guardedSteps = moveStepBefore(
      guardedSteps,
      "RESTORE_GOLDEN",
      "CONTINUE_NARROW_WORK"
    );

    guardedSteps = guardedSteps.filter(
      (step, index) =>
        !(
          step === "CONTINUE_NARROW_WORK" &&
          index < guardedSteps.indexOf("RESTORE_GOLDEN")
        )
    );

    appliedRules.push("high_severity_requires_diagnostics");
    appliedRules.push("high_severity_requires_restore_golden");
    appliedRules.push("restore_precedes_progress");
  }

  if (input.severity === "MEDIUM") {
    guardedSteps = ensureStepPresent(guardedSteps, "RUN_DIAGNOSTICS");
    guardedSteps = moveStepBefore(
      guardedSteps,
      "RUN_DIAGNOSTICS",
      "CONTINUE_NARROW_WORK"
    );

    appliedRules.push("medium_severity_requires_diagnostics_before_progress");
  }

  return {
    guardedSteps: uniqueSteps(guardedSteps),
    appliedRules
  };
}
