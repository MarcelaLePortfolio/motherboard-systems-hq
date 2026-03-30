/*
Phase 372 — Replay Violation Code Normalization

Purpose:
Normalize replay verifier violations into deterministic codes so
verification behavior can be consumed without brittle string matching.

Properties:
- Deterministic
- Read only
- No runtime coupling
- No execution authority
*/

export type ReplayViolationCode =
  | "REPLAY_PAYLOAD_MISSING"
  | "REPLAY_ID_MISSING"
  | "REPLAY_EVENTS_ARRAY_MISSING"
  | "REPLAY_EMPTY"
  | "EVENT_MISSING"
  | "MISSING_ID"
  | "MISSING_SEQUENCE"
  | "INVALID_SEQUENCE"
  | "MISSING_TIMESTAMP"
  | "INVALID_TIMESTAMP"
  | "MISSING_TYPE"
  | "DUPLICATE_SEQUENCE"
  | "EVENT_ORDERING"
  | "UNKNOWN";

export type ReplayViolation = {
  code: ReplayViolationCode;
  detail: string;
};

export function normalizeViolation(message: string): ReplayViolation {
  if (message.includes("Replay payload missing")) {
    return { code: "REPLAY_PAYLOAD_MISSING", detail: message };
  }

  if (message.includes("Replay missing replayId")) {
    return { code: "REPLAY_ID_MISSING", detail: message };
  }

  if (message.includes("Replay missing events array")) {
    return { code: "REPLAY_EVENTS_ARRAY_MISSING", detail: message };
  }

  if (message.includes("at least one event")) {
    return { code: "REPLAY_EMPTY", detail: message };
  }

  if (message.match(/^Event \d+ missing$/)) {
    return { code: "EVENT_MISSING", detail: message };
  }

  if (message.includes("missing id")) {
    return { code: "MISSING_ID", detail: message };
  }

  if (message.includes("missing sequence")) {
    return { code: "MISSING_SEQUENCE", detail: message };
  }

  if (message.includes("invalid sequence")) {
    return { code: "INVALID_SEQUENCE", detail: message };
  }

  if (message.includes("missing timestamp")) {
    return { code: "MISSING_TIMESTAMP", detail: message };
  }

  if (message.includes("invalid timestamp")) {
    return { code: "INVALID_TIMESTAMP", detail: message };
  }

  if (message.includes("missing type")) {
    return { code: "MISSING_TYPE", detail: message };
  }

  if (message.includes("duplicate sequence")) {
    return { code: "DUPLICATE_SEQUENCE", detail: message };
  }

  if (message.includes("ordering")) {
    return { code: "EVENT_ORDERING", detail: message };
  }

  return {
    code: "UNKNOWN",
    detail: message
  };
}

export function normalizeViolations(messages: string[]): ReplayViolation[] {
  return messages.map(normalizeViolation);
}
