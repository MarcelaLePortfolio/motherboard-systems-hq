/*
PHASE 77 — ADAPTATION GUARDRAILS
Deterministic safety ordering enforcement.
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

function ensureStep(steps: PlaybookStep[], step: PlaybookStep) {
  return steps.includes(step) ? steps : [...steps, step];
}

function enforceOrder(
  steps: PlaybookStep[],
  first: PlaybookStep,
  second: PlaybookStep
) {
  const filtered = steps.filter(
    s => s !== first && s !== second
  );

  return [first, second, ...filtered];
}

export function applyAdaptationGuardrails(
  input: GuardrailInput
): GuardrailResult {

  let steps = uniqueSteps(input.orderedSteps);
  const rules: string[] = [];

  if (input.severity === "HIGH") {

    steps = ensureStep(steps,"RUN_DIAGNOSTICS");
    steps = ensureStep(steps,"RESTORE_GOLDEN");

    steps = enforceOrder(
      steps,
      "RUN_DIAGNOSTICS",
      "RESTORE_GOLDEN"
    );

    if (steps.includes("CONTINUE_NARROW_WORK")) {

      steps = steps.filter(
        s => s !== "CONTINUE_NARROW_WORK"
      );

      steps.push("CONTINUE_NARROW_WORK");

    }

    rules.push("high_requires_diagnostics");
    rules.push("high_requires_restore");
    rules.push("recovery_precedes_progress");

  }

  if (input.severity === "MEDIUM") {

    steps = ensureStep(steps,"RUN_DIAGNOSTICS");

    steps = steps.filter(
      s => s !== "RUN_DIAGNOSTICS"
    );

    steps.unshift("RUN_DIAGNOSTICS");

    rules.push("medium_requires_diagnostics");

  }

  return {

    guardedSteps: uniqueSteps(steps),
    appliedRules: rules

  };

}
