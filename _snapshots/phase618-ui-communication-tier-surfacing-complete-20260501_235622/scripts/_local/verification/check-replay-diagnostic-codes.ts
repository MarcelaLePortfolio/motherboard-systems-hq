import { runReplayFixtureValidation } from "../../../src/governance_investigation/verification/replay_fixture_runner";
import { attachViolationDiagnostics } from "../../../src/governance_investigation/verification/replay_fixture_diagnostics";
import type { ReplayViolationCode } from "../../../src/governance_investigation/verification/replay_violation_codes";

type ExpectedDiagnostic = {
  fixture: string;
  codes: ReplayViolationCode[];
};

const EXPECTED: ExpectedDiagnostic[] = [
  { fixture: "valid replay", codes: [] },
  { fixture: "out of order", codes: ["EVENT_ORDERING"] },
  { fixture: "duplicate sequence", codes: ["DUPLICATE_SEQUENCE", "EVENT_ORDERING"] },
  { fixture: "empty events", codes: ["REPLAY_EMPTY"] },
  { fixture: "malformed timestamp", codes: ["INVALID_TIMESTAMP"] },
  { fixture: "missing field", codes: ["MISSING_ID"] },
  { fixture: "missing sequence", codes: ["MISSING_SEQUENCE"] },
  { fixture: "missing timestamp", codes: ["MISSING_TIMESTAMP"] },
  { fixture: "missing type", codes: ["MISSING_TYPE"] },
  { fixture: "missing replay id", codes: ["REPLAY_ID_MISSING"] },
  { fixture: "missing events array", codes: ["REPLAY_EVENTS_ARRAY_MISSING"] }
];

function main() {
  const rawResults = runReplayFixtureValidation();
  const results = attachViolationDiagnostics(rawResults);

  const mismatches = results.flatMap(result => {
    const expected = EXPECTED.find(entry => entry.fixture === result.fixture);

    if (!expected) {
      return [
        {
          fixture: result.fixture,
          problem: "missing expected diagnostic fixture mapping"
        }
      ];
    }

    const actualCodes = result.violationDiagnostics.map(diagnostic => diagnostic.code);
    const matches =
      actualCodes.length === expected.codes.length &&
      actualCodes.every((code, index) => code === expected.codes[index]);

    console.log(
      JSON.stringify({
        fixture: result.fixture,
        expectedCodes: expected.codes,
        actualCodes,
        pass: matches
      })
    );

    return matches
      ? []
      : [
          {
            fixture: result.fixture,
            expectedCodes: expected.codes,
            actualCodes
          }
        ];
  });

  if (mismatches.length > 0) {
    console.error(
      JSON.stringify({
        ok: false,
        mismatchCount: mismatches.length,
        mismatches
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
}

main();
