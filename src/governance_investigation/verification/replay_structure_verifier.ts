/*
Phase 370 — Replay Structure Verifier
Purpose:
Provide deterministic structural verification of governance replay output.

Constraints:
- Pure function
- No runtime coupling
- No mutation
- No execution authority
- Verification only
*/

export type ReplayEvent = {
  id: string
  type: string
  timestamp: number
}

export type ReplayStructure = {
  events: ReplayEvent[]
}

export type ReplayVerificationResult = {
  valid: boolean
  violations: string[]
}

export function verifyReplayStructure(
  replay: ReplayStructure
): ReplayVerificationResult {

  const violations: string[] = []

  if (!replay) {
    violations.push("Replay structure missing")
    return { valid:false, violations }
  }

  if (!Array.isArray(replay.events)) {
    violations.push("Replay events must be array")
    return { valid:false, violations }
  }

  for (let i = 0; i < replay.events.length; i++) {

    const event = replay.events[i]

    if (!event.id) {
      violations.push(`Event ${i} missing id`)
    }

    if (!event.type) {
      violations.push(`Event ${i} missing type`)
    }

    if (typeof event.timestamp !== "number") {
      violations.push(`Event ${i} invalid timestamp`)
    }

    if (i > 0) {
      if (event.timestamp < replay.events[i-1].timestamp) {
        violations.push("Event ordering violation")
      }
    }

  }

  return {
    valid: violations.length === 0,
    violations
  }

}
