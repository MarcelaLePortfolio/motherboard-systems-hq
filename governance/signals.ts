/*
────────────────────────────────
GOVERNANCE SIGNALS
Phase 97.5 — Signals
Minimal structural signal model.
No runtime emission.
────────────────────────────────
*/

import type { GovernanceRole, GovernanceCapability } from "./authorityModel";
import type { GovernanceAgentId, GovernanceWorkerId } from "./mappings";

export type GovernanceSignalType =
  | "governance_snapshot"
  | "governance_violation"
  | "governance_verification"
  | "governance_diagnostic";

export interface GovernanceSnapshotSignal {
  type: "governance_snapshot";
  roles: GovernanceRole[];
  capabilities: GovernanceCapability[];
  agents: GovernanceAgentId[];
  workers: GovernanceWorkerId[];
  ts: number;
}

export interface GovernanceViolationSignal {
  type: "governance_violation";
  subject: string;
  rule: string;
  ts: number;
}

export interface GovernanceVerificationSignal {
  type: "governance_verification";
  check: string;
  ok: boolean;
  ts: number;
}

export interface GovernanceDiagnosticSignal {
  type: "governance_diagnostic";
  message: string;
  ts: number;
}

export type GovernanceSignal =
  | GovernanceSnapshotSignal
  | GovernanceViolationSignal
  | GovernanceVerificationSignal
  | GovernanceDiagnosticSignal;
