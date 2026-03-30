import { runReplayFixtureValidation } from "../../../src/governance_investigation/verification/replay_fixture_runner";
import { summarizeReplayFixtureValidation } from "../../../src/governance_investigation/verification/replay_fixture_summary";
import { attachViolationDiagnostics } from "../../../src/governance_investigation/verification/replay_fixture_diagnostics";

function main() {
  const rawResults = runReplayFixtureValidation();
  const results = attachViolationDiagnostics(rawResults);
  const summary = summarizeReplayFixtureValidation(rawResults);

  for (const result of results) {
    console.log(JSON.stringify(result));
  }

  console.log(JSON.stringify(summary));

  if (!summary.ok) {
    process.exit(1);
  }
}

main();
