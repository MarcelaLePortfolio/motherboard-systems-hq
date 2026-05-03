/*
────────────────────────────────
GOVERNANCE GUARDS
Phase 97.4 — Guards
Minimal structural guard layer.
Pure checks only.
────────────────────────────────
*/

import type {
  GovernanceCapability,
  GovernanceRole,
} from "./authorityModel";
import type {
  GovernanceAgentId,
  GovernanceMappingModel,
  GovernanceWorkerId,
} from "./mappings";

export interface GovernanceGuardResult {
  ok: boolean;
  reason?: string;
}

export interface GovernanceGuardContext {
  role?: GovernanceRole;
  capability?: GovernanceCapability;
  agent?: GovernanceAgentId;
  worker?: GovernanceWorkerId;
}

export function hasRoleCapability(
  model: GovernanceMappingModel,
  role: GovernanceRole,
  capability: GovernanceCapability,
): boolean {
  const entry = model.roleCapabilities.find((item) => item.role === role);

  if (!entry) {
    return false;
  }

  return entry.capabilities.includes(capability);
}

export function isAgentAssignedRole(
  model: GovernanceMappingModel,
  agent: GovernanceAgentId,
  role: GovernanceRole,
): boolean {
  return model.agentRoles.some(
    (item) => item.agent === agent && item.role === role,
  );
}

export function isWorkerAssignedRole(
  model: GovernanceMappingModel,
  worker: GovernanceWorkerId,
  role: GovernanceRole,
): boolean {
  return model.workerRoles.some(
    (item) => item.worker === worker && item.role === role,
  );
}

export function verifyRoleCapability(
  model: GovernanceMappingModel,
  role: GovernanceRole,
  capability: GovernanceCapability,
): GovernanceGuardResult {
  if (!hasRoleCapability(model, role, capability)) {
    return {
      ok: false,
      reason: `role:${role} lacks capability:${capability}`,
    };
  }

  return { ok: true };
}

export function verifyAgentRole(
  model: GovernanceMappingModel,
  agent: GovernanceAgentId,
  role: GovernanceRole,
): GovernanceGuardResult {
  if (!isAgentAssignedRole(model, agent, role)) {
    return {
      ok: false,
      reason: `agent:${agent} not assigned role:${role}`,
    };
  }

  return { ok: true };
}

export function verifyWorkerRole(
  model: GovernanceMappingModel,
  worker: GovernanceWorkerId,
  role: GovernanceRole,
): GovernanceGuardResult {
  if (!isWorkerAssignedRole(model, worker, role)) {
    return {
      ok: false,
      reason: `worker:${worker} not assigned role:${role}`,
    };
  }

  return { ok: true };
}
