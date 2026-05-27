import { resolveOperatorRunbook } from "../dashboard/src/operator/runbooks/operatorRunbookResolver";

type Scenario = {
  name: string;
  input: {
    diagnosticsClean: boolean;
    driftDetected: boolean;
    structuralRisk: boolean;
  };
  expected: {
    id: string;
    continueSafe: boolean;
    risk: string;
    state: string;
  };
};

const scenarios: Scenario[] = [
  {
    name: "stable-continue",
    input: {
      diagnosticsClean: true,
      driftDetected: false,
      structuralRisk: false
    },
    expected: {
      id: "RUNBOOK_STABLE_CONTINUE",
      continueSafe: true,
      risk: "SAFE",
      state: "STABLE"
    }
  },
  {
    name: "investigate-drift",
    input: {
      diagnosticsClean: true,
      driftDetected: true,
      structuralRisk: false
    },
    expected: {
      id: "RUNBOOK_INVESTIGATE_DRIFT",
      continueSafe: false,
      risk: "MEDIUM",
      state: "INVESTIGATE"
    }
  },
  {
    name: "observe-only",
    input: {
      diagnosticsClean: false,
      driftDetected: false,
      structuralRisk: false
    },
    expected: {
      id: "RUNBOOK_OBSERVE_ONLY",
      continueSafe: false,
      risk: "LOW",
      state: "OBSERVE"
    }
  },
  {
    name: "recovery-first",
    input: {
      diagnosticsClean: false,
      driftDetected: true,
      structuralRisk: true
    },
    expected: {
      id: "RUNBOOK_RECOVERY_FIRST",
      continueSafe: false,
      risk: "HIGH",
      state: "RECOVERY"
    }
  }
];

function assertEqual(label: string, actual: unknown, expected: unknown): void {
  if (actual !== expected) {
    throw new Error(`${label} mismatch: expected=${String(expected)} actual=${String(actual)}`);
  }
}

for (const scenario of scenarios) {
  const runbook = resolveOperatorRunbook(scenario.input);

  assertEqual(`${scenario.name} id`, runbook.id, scenario.expected.id);
  assertEqual(`${scenario.name} continueSafe`, runbook.continueSafe, scenario.expected.continueSafe);
  assertEqual(`${scenario.name} risk`, runbook.risk, scenario.expected.risk);
  assertEqual(`${scenario.name} state`, runbook.state, scenario.expected.state);

  console.log(`PASS ${scenario.name} -> ${runbook.id}`);
}

console.log("ALL RUNBOOK ASSERTIONS PASSED");
