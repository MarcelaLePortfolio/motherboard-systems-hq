/*
Phase 396 — Replay Violation Code Registry Completion

Purpose:
Provide a deterministic diagnostic registry for replay verification proofs.
Includes all pathological fixture violation codes and exports both named and
default registry shapes for stable module resolution.

Safety:
Read-only constants only.
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
  }
} as const;

export type ReplayViolationCode =
  keyof typeof REPLAY_VIOLATION_CODES;

export default REPLAY_VIOLATION_CODES;
