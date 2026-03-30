/*
Phase 371 — Replay Structure Verifier Hardening

Purpose:
Provide deterministic structural replay verification with explicit
required-field checks, non-empty event enforcement, sequence validation,
and ISO timestamp validation.

Properties:
- Read only
- Deterministic
- No runtime coupling
- No reducer coupling
- No execution authority
*/

export type ReplayStructureEvent = {
  id: string;
  sequence: number;
  timestamp: string;
  type: string;
};

export type ReplayStructure = {
  replayId: string;
  events: ReplayStructureEvent[];
};

export type ReplayStructureVerificationResult = {
  valid: boolean;
  violations: string[];
};

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function isPositiveInteger(value: unknown): value is number {
  return typeof value === "number" && Number.isInteger(value) && value > 0;
}

function isStrictIsoTimestamp(value: unknown): value is string {
  if (!isNonEmptyString(value)) {
    return false;
  }

  const parsed = new Date(value);

  if (Number.isNaN(parsed.getTime())) {
    return false;
  }

  return parsed.toISOString() === value;
}

export function verifyReplayStructure(
  replay: ReplayStructure
): ReplayStructureVerificationResult {
  const violations: string[] = [];

  if (!replay || typeof replay !== "object") {
    return {
      valid: false,
      violations: ["Replay payload missing"]
    };
  }

  if (!isNonEmptyString(replay.replayId)) {
    violations.push("Replay missing replayId");
  }

  if (!Array.isArray(replay.events)) {
    violations.push("Replay missing events array");
  } else if (replay.events.length === 0) {
    violations.push("Replay must contain at least one event");
  }

  if (!Array.isArray(replay.events)) {
    return {
      valid: violations.length === 0,
      violations
    };
  }

  const seenSequences = new Set<number>();
  let previousSequence: number | null = null;

  replay.events.forEach((event, index) => {
    if (!event || typeof event !== "object") {
      violations.push(`Event ${index} missing`);
      return;
    }

    if (!isNonEmptyString(event.id)) {
      violations.push(`Event ${index} missing id`);
    }

    if (!isPositiveInteger(event.sequence)) {
      violations.push(`Event ${index} invalid sequence`);
    }

    if (!isStrictIsoTimestamp(event.timestamp)) {
      violations.push(`Event ${index} invalid timestamp`);
    }

    if (!isNonEmptyString(event.type)) {
      violations.push(`Event ${index} missing type`);
    }

    if (isPositiveInteger(event.sequence)) {
      if (seenSequences.has(event.sequence)) {
        violations.push(`Event ${index} duplicate sequence`);
      }

      if (
        previousSequence !== null &&
        event.sequence <= previousSequence
      ) {
        violations.push("Event ordering violation");
      }

      seenSequences.add(event.sequence);
      previousSequence = event.sequence;
    }
  });

  return {
    valid: violations.length === 0,
    violations
  };
}
