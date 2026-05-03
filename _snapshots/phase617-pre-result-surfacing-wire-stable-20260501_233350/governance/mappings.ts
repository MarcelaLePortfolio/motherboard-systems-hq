/*
────────────────────────────────
GOVERNANCE MAPPINGS
Phase 97.3 — Mapping
Structural mapping only.
No behavior.
────────────────────────────────
*/

import type { GovernanceCapability, GovernanceRole } from "./authorityModel";

export type GovernanceAgentId =
  | "matilda"
  | "atlas"
  | "cade"
  | "effie";

export type GovernanceWorkerId =
  | "dashboard"
  | "workerA"
  | "workerB"
  | "policy";

export interface RoleCapabilityMapping {
  role: GovernanceRole;
  capabilities: GovernanceCapability[];
}

export interface AgentRoleMapping {
  agent: GovernanceAgentId;
  role: GovernanceRole;
}

export interface WorkerRoleMapping {
  worker: GovernanceWorkerId;
  role: GovernanceRole;
}

export interface GovernanceMappingModel {
  roleCapabilities: RoleCapabilityMapping[];
  agentRoles: AgentRoleMapping[];
  workerRoles: WorkerRoleMapping[];
}

export const GOVERNANCE_MAPPINGS: GovernanceMappingModel = {
  roleCapabilities: [
    {
      role: "operator",
      capabilities: ["read", "write", "execute", "verify", "register"],
    },
    {
      role: "system",
      capabilities: ["read", "verify", "register"],
    },
    {
      role: "worker",
      capabilities: ["read", "execute"],
    },
    {
      role: "governance",
      capabilities: ["read", "verify"],
    },
  ],
  agentRoles: [
    {
      agent: "matilda",
      role: "operator",
    },
    {
      agent: "atlas",
      role: "system",
    },
    {
      agent: "cade",
      role: "worker",
    },
    {
      agent: "effie",
      role: "governance",
    },
  ],
  workerRoles: [
    {
      worker: "dashboard",
      role: "operator",
    },
    {
      worker: "workerA",
      role: "worker",
    },
    {
      worker: "workerB",
      role: "worker",
    },
    {
      worker: "policy",
      role: "governance",
    },
  ],
};
