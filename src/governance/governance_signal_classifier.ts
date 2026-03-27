/*
PHASE 287 — GOVERNANCE SIGNAL CLASSIFIER (FIRST CODE ARTIFACT)

Purpose:
First safe governance module implementation.

This module is intentionally:

READ ONLY
ADVISORY ONLY
NON-EXECUTING
NON-ROUTING
NON-MUTATING

SAFETY BOUNDARY:

This module MUST NEVER:

Modify tasks
Modify agents
Interact with execution routing
Write to registry
Trigger automation
Enforce policy

This module ONLY:

Classifies signals
Produces advisory outputs
Produces operator awareness signals
Produces governance audit outputs

Architecture rule:

Pure function behavior only.

Input → Classification → Output

No side effects allowed.
*/

export type GovernanceSignal = {

    signal_id: string
    signal_type: string

    source:

        | "operator"
        | "telemetry"
        | "policy"
        | "agent"
        | "task"

    severity:

        | "info"
        | "notice"
        | "caution"
        | "risk"

    ts: number

    payload?: Record<string, unknown>

}

export type GovernanceClassification = {

    classification:

        | "SAFE"
        | "CAUTION"
        | "RISK"
        | "UNKNOWN"

    advisory_message: string

    governance_safe: true

}

export function classifyGovernanceSignal(
    signal: GovernanceSignal
): GovernanceClassification {

    /*
    Phase 287 rule:

    Deterministic classification only.
    No external access.
    No mutation.
    */

    if (!signal || !signal.signal_type) {

        return {

            classification: "UNKNOWN",

            advisory_message:
                "Signal missing required fields",

            governance_safe: true

        }

    }

    if (signal.severity === "risk") {

        return {

            classification: "RISK",

            advisory_message:
                "Risk level governance signal detected",

            governance_safe: true

        }

    }

    if (signal.severity === "caution") {

        return {

            classification: "CAUTION",

            advisory_message:
                "Caution level governance signal detected",

            governance_safe: true

        }

    }

    return {

        classification: "SAFE",

        advisory_message:
            "Signal classified as safe",

        governance_safe: true

    }

}
