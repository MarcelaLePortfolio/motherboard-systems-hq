/*
Phase 371 — Replay Fixture Runner

Purpose:
Execute deterministic structural verification against replay fixtures.

Properties:
- Read only
- Deterministic
- No runtime coupling
- No reducer coupling
- No execution authority
*/

import {
  VALID_REPLAY_FIXTURE,
  OUT_OF_ORDER_FIXTURE,
  DUPLICATE_SEQUENCE_FIXTURE,
  EMPTY_EVENTS_FIXTURE,
  MALFORMED_TIMESTAMP_FIXTURE,
  ReplayFixture
} from "./replay_fixture_library";

import { verifyReplayStructure } from "./replay_structure_verifier";

type FixtureExpectation = {
  name: string;
  fixture: ReplayFixture;
  shouldPass: boolean;
};

const FIXTURES: FixtureExpectation[] = [
  {
    name: "valid replay",
    fixture: VALID_REPLAY_FIXTURE,
    shouldPass: true
  },
  {
    name: "out of order",
    fixture: OUT_OF_ORDER_FIXTURE,
    shouldPass: false
  },
  {
    name: "duplicate sequence",
    fixture: DUPLICATE_SEQUENCE_FIXTURE,
    shouldPass: false
  },
  {
    name: "empty events",
    fixture: EMPTY_EVENTS_FIXTURE,
    shouldPass: false
  },
  {
    name: "malformed timestamp",
    fixture: MALFORMED_TIMESTAMP_FIXTURE,
    shouldPass: false
  }
];

export function runReplayFixtureValidation() {
  return FIXTURES.map(test => {
    const result = verifyReplayStructure(test.fixture);

    return {
      fixture: test.name,
      expected: test.shouldPass,
      actual: result.valid,
      pass: result.valid === test.shouldPass,
      violations: result.violations
    };
  });
}
