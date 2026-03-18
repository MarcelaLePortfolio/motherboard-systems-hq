/*
PHASE 87 — SITUATION SUMMARY INTEGRATION SMOKE

Purpose:

Verify adapter + composer produce deterministic output.

Rules:

No reducers
No IO
No logging
No dashboard
No execution coupling

Test only verifies stable composition behavior.

*/

import { adaptSituationSummaryInputs } from "./situationSummaryInputAdapter";
import { composeSituationSummary } from "./situationSummaryComposer";

function runSmoke() {

  const signals = {

    stability: "stable",
    executionRisk: "none",
    cognition: "consistent",
    signalCoherence: "coherent",
    operatorAttention: "none"

  };

  const inputs =
    adaptSituationSummaryInputs(signals);

  const summary =
    composeSituationSummary(inputs);

  if (!summary) {
    throw new Error("Summary missing");
  }

  if (!summary.lines) {
    throw new Error("Summary lines missing");
  }

  if (summary.lines.length !== 5) {
    throw new Error("Unexpected summary structure");
  }

  return "PASS";

}

const result = runSmoke();

if (result !== "PASS") {
  throw new Error("Integration smoke failed");
}

