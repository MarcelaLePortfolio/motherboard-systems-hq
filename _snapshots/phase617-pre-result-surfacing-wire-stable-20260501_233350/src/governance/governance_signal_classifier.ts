/*
PHASE 288 — GOVERNANCE SIGNAL CLASSIFIER STRUCTURAL HARDENING

Purpose:
Strengthen the first governance code artifact without introducing runtime
integration, execution influence, or mutation capability.

This module remains:

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

Input -> Classification -> Output

No side effects allowed.
*/

export type GovernanceSignalSource =
    | "operator"
    | "telemetry"
    | "policy"
    | "agent"
    | "task"

export type GovernanceSignalSeverity =
    | "info"
    | "notice"
    | "caution"
    | "risk"

export type GovernanceSignal = {
    signal_id: string
    signal_type: string
    source: GovernanceSignalSource
    severity: GovernanceSignalSeverity
    ts: number
    payload?: Record<string, unknown>
}

export type GovernanceClassificationLabel =
    | "SAFE"
    | "CAUTION"
    | "RISK"
    | "UNKNOWN"

export type GovernanceClassificationReason =
    | "MISSING_REQUIRED_FIELDS"
    | "RISK_SIGNAL_DETECTED"
    | "CAUTION_SIGNAL_DETECTED"
    | "SAFE_SIGNAL_DETECTED"

export type GovernanceClassification = {
    classification: GovernanceClassificationLabel
    reason: GovernanceClassificationReason
    advisory_message: string
    governance_safe: true
    deterministic: true
}

export type GovernanceAuditRecord = {
    signal_id: string
    signal_type: string
    classification: GovernanceClassificationLabel
    reason: GovernanceClassificationReason
    ts: number
    governance_safe: true
}

function hasRequiredSignalFields(
    signal: GovernanceSignal | null | undefined
): signal is GovernanceSignal {
    return Boolean(
        signal &&
        signal.signal_id &&
        signal.signal_type &&
        signal.source &&
        signal.severity &&
        typeof signal.ts === "number"
    )
}

export function classifyGovernanceSignal(
    signal: GovernanceSignal | null | undefined
): GovernanceClassification {
    /*
    Phase 288 rule:

    Deterministic classification only.
    No external access.
    No mutation.
    No side effects.
    */

    if (!hasRequiredSignalFields(signal)) {
        return {
            classification: "UNKNOWN",
            reason: "MISSING_REQUIRED_FIELDS",
            advisory_message: "Signal missing required fields",
            governance_safe: true,
            deterministic: true
        }
    }

    if (signal.severity === "risk") {
        return {
            classification: "RISK",
            reason: "RISK_SIGNAL_DETECTED",
            advisory_message: "Risk level governance signal detected",
            governance_safe: true,
            deterministic: true
        }
    }

    if (signal.severity === "caution") {
        return {
            classification: "CAUTION",
            reason: "CAUTION_SIGNAL_DETECTED",
            advisory_message: "Caution level governance signal detected",
            governance_safe: true,
            deterministic: true
        }
    }

    return {
        classification: "SAFE",
        reason: "SAFE_SIGNAL_DETECTED",
        advisory_message: "Signal classified as safe",
        governance_safe: true,
        deterministic: true
    }
}

export function createGovernanceAuditRecord(
    signal: GovernanceSignal | null | undefined,
    classification: GovernanceClassification
): GovernanceAuditRecord {
    return {
        signal_id: signal?.signal_id ?? "unknown-signal-id",
        signal_type: signal?.signal_type ?? "unknown-signal-type",
        classification: classification.classification,
        reason: classification.reason,
        ts: signal?.ts ?? 0,
        governance_safe: true
    }
}
