#!/usr/bin/env bash
set -euo pipefail

cat > src/governance_investigation/verification/replay_violation_codes.ts << 'TS'
/*
Phase 396 — Replay Violation Code Registry Completion
Phase 702 — Replay Diagnostic Export Repair

Purpose:
Provide a deterministic diagnostic registry for replay verification proofs.
Exports registry constants, violation typing, and normalization helpers for
read-only verification diagnostics.

Safety:
Read-only constants + pure normalization only.
No runtime coupling.
No execution integration.
No mutation surfaces.
*/

export const REPLAY_VIOLATION_CODES = {
  REPLAY_DUPLICATE_TERMINAL_EVENT: {
    code: "REPLAY_DUPLICATE_TERMINAL_EVENT",
    severity: "error",
    description: "Replay contains more than one terminal event."
  },

  REPLAY_EVENT_ORDER_VIOLATION: {
    code: "REPLAY_EVENT_ORDER_VIOLATION",
    severity: "error",
    description: "Replay event ordering violates deterministic sequence rules."
  },

  REPLAY_ROOT_EVENT_MISSING: {
    code: "REPLAY_ROOT_EVENT_MISSING",
    severity: "error",
    description: "Replay is missing the required root event."
  },

  REPLAY_UNKNOWN_EVENT: {
    code: "REPLAY_UNKNOWN_EVENT",
    severity: "error",
    description: "Replay contains an unknown event type."
  },

  EVENT_ORDERING: {
    code: "EVENT_ORDERING",
    severity: "error",
    description: "Replay events are not ordered deterministically."
  },

  DUPLICATE_SEQUENCE: {
    code: "DUPLICATE_SEQUENCE",
    severity: "error",
    description: "Replay contains duplicate sequence values."
  },

  REPLAY_EMPTY: {
    code: "REPLAY_EMPTY",
    severity: "error",
    description: "Replay contains no events."
  },

  INVALID_TIMESTAMP: {
    code: "INVALID_TIMESTAMP",
    severity: "error",
    description: "Replay contains an invalid timestamp."
  },

  MISSING_ID: {
    code: "MISSING_ID",
    severity: "error",
    description: "Replay event is missing an id."
  },

  MISSING_SEQUENCE: {
    code: "MISSING_SEQUENCE",
    severity: "error",
    description: "Replay event is missing a sequence."
  },

  MISSING_TIMESTAMP: {
    code: "MISSING_TIMESTAMP",
    severity: "error",
    description: "Replay event is missing a timestamp."
  },

  MISSING_TYPE: {
    code: "MISSING_TYPE",
    severity: "error",
    description: "Replay event is missing a type."
  },

  REPLAY_ID_MISSING: {
    code: "REPLAY_ID_MISSING",
    severity: "error",
    description: "Replay is missing an id."
  },

  REPLAY_EVENTS_ARRAY_MISSING: {
    code: "REPLAY_EVENTS_ARRAY_MISSING",
    severity: "error",
    description: "Replay is missing an events array."
  }
} as const;

export type ReplayViolationCode = keyof typeof REPLAY_VIOLATION_CODES;

export type ReplayViolation = {
  code: ReplayViolationCode | string;
  severity: string;
  description: string;
};

export function normalizeViolations(violations: string[]): ReplayViolation[] {
  return violations.map((violation) => {
    const known = REPLAY_VIOLATION_CODES[violation as ReplayViolationCode];

    if (known) {
      return {
        code: known.code,
        severity: known.severity,
        description: known.description
      };
    }

    return {
      code: violation,
      severity: "error",
      description: `Unregistered replay violation: ${violation}`
    };
  });
}

export default REPLAY_VIOLATION_CODES;
TS

git add src/governance_investigation/verification/replay_violation_codes.ts PHASE702_STEP5I_INSPECT_REPLAY_EXPORTS.sh PHASE702_STEP5J_PATCH_REPLAY_DIAGNOSTIC_EXPORTS.sh
git commit -m "Phase 702: repair replay diagnostic exports for validation"
git push

npm run verify:replay

git status --short
