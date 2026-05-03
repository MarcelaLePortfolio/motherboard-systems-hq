/*
Phase 372 — Replay Structure Verifier Boundary Hardening

Purpose:
Accept unknown replay payloads at the verifier boundary and validate
them deterministically without requiring callers to satisfy a trusted
compile-time structure first.

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

function isObjectRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

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
  replay: unknown
): ReplayStructureVerificationResult {
  const violations: string[] = [];

  if (!isObjectRecord(replay)) {
    return {
      valid: false,
      violations: ["Replay payload missing"]
    };
  }

  const replayId = replay["replayId"];
  const events = replay["events"];

  if (!isNonEmptyString(replayId)) {
    violations.push("Replay missing replayId");
  }

  if (!Array.isArray(events)) {
    violations.push("Replay missing events array");

    return {
      valid: false,
      violations
    };
  }

  if (events.length === 0) {
    violations.push("Replay must contain at least one event");
  }

  const seenSequences = new Set<number>();
  let previousSequence: number | null = null;

  events.forEach((event, index) => {
    if (!isObjectRecord(event)) {
      violations.push(`Event ${index} missing`);
      return;
    }

    const id = event["id"];
    const sequence = event["sequence"];
    const timestamp = event["timestamp"];
    const type = event["type"];

    if (!isNonEmptyString(id)) {
      violations.push(`Event ${index} missing id`);
    }

    if (sequence === undefined) {
      violations.push(`Event ${index} missing sequence`);
    } else if (!isPositiveInteger(sequence)) {
      violations.push(`Event ${index} invalid sequence`);
    }

    if (timestamp === undefined) {
      violations.push(`Event ${index} missing timestamp`);
    } else if (!isStrictIsoTimestamp(timestamp)) {
      violations.push(`Event ${index} invalid timestamp`);
    }

    if (!isNonEmptyString(type)) {
      violations.push(`Event ${index} missing type`);
    }

    if (isPositiveInteger(sequence)) {
      if (seenSequences.has(sequence)) {
        violations.push(`Event ${index} duplicate sequence`);
      }

      if (previousSequence !== null && sequence <= previousSequence) {
        violations.push("Event ordering violation");
      }

      seenSequences.add(sequence);
      previousSequence = sequence;
    }
  });

  return {
    valid: violations.length === 0,
    violations
  };
}
