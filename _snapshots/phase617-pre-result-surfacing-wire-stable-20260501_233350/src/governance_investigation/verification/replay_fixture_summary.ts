/*
Phase 371 — Replay Fixture Summary Utility

Purpose:
Provide deterministic aggregation for replay fixture validation results.

Properties:
- Read only
- Deterministic
- No runtime coupling
- No reducer coupling
- No execution authority
*/

export type ReplayFixtureValidationResult = {
  fixture: string;
  expected: boolean;
  actual: boolean;
  pass: boolean;
  violations: string[];
};

export type ReplayFixtureValidationSummary = {
  ok: boolean;
  fixtureCount: number;
  passCount: number;
  failCount: number;
  failingFixtures: string[];
};

export function summarizeReplayFixtureValidation(
  results: ReplayFixtureValidationResult[]
): ReplayFixtureValidationSummary {
  const failingFixtures = results
    .filter(result => !result.pass)
    .map(result => result.fixture);

  return {
    ok: failingFixtures.length === 0,
    fixtureCount: results.length,
    passCount: results.length - failingFixtures.length,
    failCount: failingFixtures.length,
    failingFixtures
  };
}
