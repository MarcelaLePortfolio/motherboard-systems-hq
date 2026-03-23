import {
  synthesizeOperationalConfidence,
  verifyOperationalConfidenceDeterminism,
  type OperationalConfidenceInputs,
} from "../../src/cognition/confidence";

const STABLE_INPUT: OperationalConfidenceInputs = {
  governanceHealth: { score: 100 },
  runtimeHealth: { score: 80 },
  cognitionCompleteness: { score: 80 },
  signalConsistency: { score: 75 },
};

const DEGRADED_INPUT: OperationalConfidenceInputs = {
  governanceHealth: { score: 40 },
  runtimeHealth: { score: 50 },
  cognitionCompleteness: { score: 45 },
  signalConsistency: { score: 35 },
};

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runPhase99_2OperationalConfidenceSmoke(): void {
  verifyOperationalConfidenceDeterminism();

  const stable = synthesizeOperationalConfidence(STABLE_INPUT);
  assert(stable.score === 85, `Expected stable score 85, received ${stable.score}.`);
  assert(stable.level === "HIGH", `Expected stable level HIGH, received ${stable.level}.`);
  assert(
    stable.reasoning.factors.length === 4,
    `Expected 4 stable factors, received ${stable.reasoning.factors.length}.`,
  );

  const degraded = synthesizeOperationalConfidence(DEGRADED_INPUT);
  assert(
    degraded.score === 43,
    `Expected degraded score 43, received ${degraded.score}.`,
  );
  assert(
    degraded.level === "LOW",
    `Expected degraded level LOW, received ${degraded.level}.`,
  );
  assert(
    degraded.reasoning.summary.length === 4,
    `Expected 4 degraded summary lines, received ${degraded.reasoning.summary.length}.`,
  );

  console.log("phase99.2 operational confidence smoke: PASS");
}

runPhase99_2OperationalConfidenceSmoke();
