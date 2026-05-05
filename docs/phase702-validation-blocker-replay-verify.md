# Phase 702 Validation Blocker — Replay Verify

Generated: Tue May  5 11:20:56 PDT 2026

## Observed Failure

`npm run verify:replay` fails before completing because `normalizeViolations` is not available as a function.

## Failure Classification

- Validation blocker
- Not evidence that the Phase 702 UI-only status reasoning patch failed
- Located in governance replay diagnostics path

## Stack Location

- src/governance_investigation/verification/replay_fixture_diagnostics.ts
- scripts/_local/verification/check-replay-verification.ts

## Relevant File Inspection

### replay_fixture_diagnostics.ts
```ts
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
```

### replay_violation_codes references
```
src/governance_investigation/verification/replay_fixture_diagnostics.ts:16:  normalizeViolations,
src/governance_investigation/verification/replay_fixture_diagnostics.ts:18:} from "./replay_violation_codes";
src/governance_investigation/verification/replay_fixture_diagnostics.ts:38:    violationDiagnostics: normalizeViolations(result.violations)
src/governance_investigation/verification/check-pathological-fixtures.ts:15:import * as replayViolationModule from "./replay_violation_codes";
scripts/_local/verification/check-replay-diagnostic-codes.ts:3:import type { ReplayViolationCode } from "../../../src/governance_investigation/verification/replay_violation_codes";
```

## Safe Next Step

Inspect export/import mismatch before making any patch. Do not layer speculative fixes.
