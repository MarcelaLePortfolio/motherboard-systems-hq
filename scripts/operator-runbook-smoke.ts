import { resolveOperatorRunbook } from "../dashboard/src/operator/runbooks/operatorRunbookResolver";
import { formatRunbook } from "../dashboard/src/operator/runbooks/operatorRunbookFormatter";

const scenarios = [
  {
    name: "stable-continue",
    input: {
      diagnosticsClean: true,
      driftDetected: false,
      structuralRisk: false
    }
  },
  {
    name: "investigate-drift",
    input: {
      diagnosticsClean: true,
      driftDetected: true,
      structuralRisk: false
    }
  },
  {
    name: "observe-only",
    input: {
      diagnosticsClean: false,
      driftDetected: false,
      structuralRisk: false
    }
  },
  {
    name: "recovery-first",
    input: {
      diagnosticsClean: false,
      driftDetected: true,
      structuralRisk: true
    }
  }
] as const;

for (const scenario of scenarios) {
  const runbook = resolveOperatorRunbook(scenario.input);

  console.log("=".repeat(72));
  console.log(`SCENARIO: ${scenario.name}`);
  console.log(formatRunbook(runbook));
  console.log("");
}
