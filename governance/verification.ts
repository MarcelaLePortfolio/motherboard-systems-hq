/*
────────────────────────────────
GOVERNANCE VERIFICATION
Phase 97.6 — Proof Layer
Structural verification only.
Deterministic checks.
No runtime mutation.
────────────────────────────────
*/

import type { GovernanceMappingModel } from "./mappings";
import type { GovernanceRole } from "./authorityModel";

export interface GovernanceInvariantResult {
  ok: boolean;
  invariant: string;
  reason?: string;
}

export interface GovernanceVerificationReport {
  ok: boolean;
  results: GovernanceInvariantResult[];
}

function rolesExist(model: GovernanceMappingModel): GovernanceInvariantResult {
  if (!model.roleCapabilities || model.roleCapabilities.length === 0) {
    return {
      ok: false,
      invariant: "roles_exist",
      reason: "no role capability definitions present",
    };
  }

  return {
    ok: true,
    invariant: "roles_exist",
  };
}

function agentsHaveRoles(model: GovernanceMappingModel): GovernanceInvariantResult {
  const missing = model.agentRoles.filter(a => !a.role);

  if (missing.length > 0) {
    return {
      ok: false,
      invariant: "agents_have_roles",
      reason: "agent missing role assignment",
    };
  }

  return {
    ok: true,
    invariant: "agents_have_roles",
  };
}

function workersHaveRoles(model: GovernanceMappingModel): GovernanceInvariantResult {
  const missing = model.workerRoles.filter(w => !w.role);

  if (missing.length > 0) {
    return {
      ok: false,
      invariant: "workers_have_roles",
      reason: "worker missing role assignment",
    };
  }

  return {
    ok: true,
    invariant: "workers_have_roles",
  };
}

function roleReferencesValid(model: GovernanceMappingModel): GovernanceInvariantResult {
  const definedRoles = new Set<GovernanceRole>(
    model.roleCapabilities.map(r => r.role)
  );

  const invalidAgentRoles = model.agentRoles.filter(
    a => !definedRoles.has(a.role)
  );

  const invalidWorkerRoles = model.workerRoles.filter(
    w => !definedRoles.has(w.role)
  );

  if (invalidAgentRoles.length || invalidWorkerRoles.length) {
    return {
      ok: false,
      invariant: "role_references_valid",
      reason: "mapping references undefined role",
    };
  }

  return {
    ok: true,
    invariant: "role_references_valid",
  };
}

export function verifyGovernanceModel(
  model: GovernanceMappingModel,
): GovernanceVerificationReport {

  const results: GovernanceInvariantResult[] = [
    rolesExist(model),
    agentsHaveRoles(model),
    workersHaveRoles(model),
    roleReferencesValid(model),
  ];

  return {
    ok: results.every(r => r.ok),
    results,
  };
}
