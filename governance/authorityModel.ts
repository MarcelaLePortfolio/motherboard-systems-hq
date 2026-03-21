/*
────────────────────────────────
GOVERNANCE AUTHORITY MODEL
Phase 97.2 — Reference Wiring
Structural references only.
No behavior.
────────────────────────────────
*/

export type GovernanceRole =
  | "operator"
  | "system"
  | "worker"
  | "governance";

export type GovernanceCapability =
  | "read"
  | "write"
  | "execute"
  | "verify"
  | "register";

export interface AuthorityRelationship {
  role: GovernanceRole;
  capabilities: GovernanceCapability[];
}

export const AUTHORITY_BASELINE: AuthorityRelationship[] = [
  {
    role: "operator",
    capabilities: ["read","write","execute","verify","register"]
  },
  {
    role: "system",
    capabilities: ["read","verify","register"]
  },
  {
    role: "worker",
    capabilities: ["read","execute"]
  },
  {
    role: "governance",
    capabilities: ["read","verify"]
  }
];
