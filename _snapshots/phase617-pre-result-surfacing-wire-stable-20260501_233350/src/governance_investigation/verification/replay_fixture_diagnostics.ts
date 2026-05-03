/*
Phase 372 — Replay Fixture Diagnostics Layer

Purpose:
Attach normalized deterministic diagnostics to replay fixture
validation results.

Properties:
- Deterministic
- Read only
- No runtime coupling
- No execution authority
*/

import {
  normalizeViolations,
  type ReplayViolation
} from "./replay_violation_codes";

export type ReplayFixtureValidationResult = {
  fixture: string;
  expected: boolean;
  actual: boolean;
  pass: boolean;
  violations: string[];
};

export type ReplayFixtureValidationDiagnosticResult =
  ReplayFixtureValidationResult & {
    violationDiagnostics: ReplayViolation[];
  };

export function attachViolationDiagnostics(
  results: ReplayFixtureValidationResult[]
): ReplayFixtureValidationDiagnosticResult[] {
  return results.map(result => ({
    ...result,
    violationDiagnostics: normalizeViolations(result.violations)
  }));
}
