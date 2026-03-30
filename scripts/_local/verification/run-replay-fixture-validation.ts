import { runReplayFixtureValidation } from "../../../src/governance_investigation/verification/replay_fixture_runner";
import { summarizeReplayFixtureValidation } from "../../../src/governance_investigation/verification/replay_fixture_summary";

const results = runReplayFixtureValidation();
const summary = summarizeReplayFixtureValidation(results);

for (const result of results) {
  console.log(JSON.stringify(result));
}

console.log(JSON.stringify(summary));

if (!summary.ok) {
  process.exit(1);
}
