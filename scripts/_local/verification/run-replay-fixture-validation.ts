import { runReplayFixtureValidation } from "../../../src/governance_investigation/verification/replay_fixture_runner";

const results = runReplayFixtureValidation();

const failures = results.filter(result => !result.pass);

for (const result of results) {
  console.log(JSON.stringify(result));
}

if (failures.length > 0) {
  console.error(
    JSON.stringify({
      ok: false,
      failureCount: failures.length,
      failures
    })
  );
  process.exit(1);
}

console.log(
  JSON.stringify({
    ok: true,
    fixtureCount: results.length
  })
);
