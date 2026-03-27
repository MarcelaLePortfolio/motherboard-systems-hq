import { verifyGovernanceCognitionDeterminism } from "../../src/governance/governance_cognition_determinism_sentinel";
import { verifyGovernanceReplayStability } from "../../src/governance/governance_cognition_replay_verifier";
import { GOVERNANCE_FIXTURE_WARNING } from "../../src/governance/governance_fixture_corpus";

function assert(condition: unknown, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

const determinism = verifyGovernanceCognitionDeterminism();

assert(
  determinism.governance_determinism === "verified",
  "Determinism sentinel failed"
);
assert(
  determinism.cognition_replay === "stable",
  "Determinism replay state drifted"
);
assert(
  determinism.governance_consistency === "protected",
  "Determinism consistency not protected"
);

const replay = verifyGovernanceReplayStability(GOVERNANCE_FIXTURE_WARNING);

assert(replay.replay_runs === 5, "Replay verifier run count mismatch");
assert(replay.cognition_replay === "stable", "Replay verifier unstable");
assert(
  replay.governance_reliability === "verified",
  "Replay reliability not verified"
);

console.log("Phase 321 governance extended cognition smoke checks passed");
