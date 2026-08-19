/*
 * Mission Read Model
 *
 * Canonical executive-facing read model consumed by:
 *   - Mission Read Model Assembler
 *   - Mission Read API
 *   - Mission Control
 *
 * This module defines types only.
 * No runtime logic.
 */

export type MissionStage =
  | "UNKNOWN"
  | "AWAITING_DELEGATION"
  | "GOVERNANCE_VALIDATION"
  | "ENVELOPE_GATE"
  | "ENVELOPE_CREATED"
  | "ASSIGNED"
  | "RUNNING"
  | "COMPLETED";

export type MissionOwner =
  | "UNKNOWN"
  | "UNASSIGNED"
  | "GOVERNANCE"
  | "DEPARTMENT"
  | "EXECUTIVE";

export type MissionHealth =
  | "UNKNOWN"
  | "HEALTHY"
  | "WAITING"
  | "NEEDS_ATTENTION"
  | "BLOCKED"
  | "ESCALATED"
  | "COMPLETED";

export interface MissionIdentity {
  package_id: string;
  package_version: number;
  project_id: string | null;
  conversation_id: string | null;
}

export interface MissionEvidence {
  artifact_count: number;
  lifecycle_event_count: number;
  integrity_warnings: string[];
  latest_timestamp: string | null;
}

export interface MissionTimelineEntry {
  event_type?: string;
  stage?: MissionStage;
  timestamp?: string;
  [key: string]: unknown;
}

export interface MissionSummary {
  identity: MissionIdentity;
  stage: MissionStage;
  owner: MissionOwner;
  health: MissionHealth;
  awaiting: string | null;
  evidence: MissionEvidence;
}

export interface MissionReadModel extends MissionSummary {
  timeline: readonly MissionTimelineEntry[];
}
