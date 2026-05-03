/*
Phase 96.5 — Governance Verification Model

Purpose:
Provide deterministic verification helpers for worker, permission,
and capability governance contracts.

This file introduces proof-oriented structure only.
No runtime behavior is modified.

Doctrine alignment:
Human decides.
System informs.
Automation executes bounded work.
*/

import type { WorkerDefinition } from "./workerModel";
import { WORKER_GOVERNANCE_INVARIANT } from "./workerModel";
import type { PermissionDefinition } from "./permissionModel";
import { PERMISSION_GOVERNANCE_INVARIANT } from "./permissionModel";
import type { CapabilityDefinition } from "./capabilityModel";
import { CAPABILITY_GOVERNANCE_INVARIANT } from "./capabilityModel";

export interface GovernanceVerificationResult {
  ok: boolean;
  violations: string[];
}

export function verifyWorkerDefinition(
  worker: WorkerDefinition,
): GovernanceVerificationResult {
  const violations: string[] = [];

  if (worker.operatorOverride !== true) {
    violations.push("worker.operatorOverride must remain true.");
  }

  if (worker.governanceImpact !== "none") {
    violations.push('worker.governanceImpact must remain "none".');
  }

  if (worker.authority === "bounded_execution" && worker.requiresPolicyGrant !== true) {
    violations.push(
      "workers with bounded execution authority must require policy grant.",
    );
  }

  return {
    ok: violations.length === 0,
    violations,
  };
}

export function verifyPermissionDefinition(
  permission: PermissionDefinition,
): GovernanceVerificationResult {
  const violations: string[] = [];

  if (permission.operatorRetainsAuthority !== true) {
    violations.push("permission.operatorRetainsAuthority must remain true.");
  }

  if (
    permission.role !== "operator" &&
    permission.authority === "full"
  ) {
    violations.push('only operator role may hold "full" authority.');
  }

  if (
    permission.role === "worker" &&
    permission.constraints.includes("no_self_authorization") !== true
  ) {
    violations.push("worker permission definitions must include no_self_authorization.");
  }

  return {
    ok: violations.length === 0,
    violations,
  };
}

export function verifyCapabilityDefinition(
  capability: CapabilityDefinition,
): GovernanceVerificationResult {
  const violations: string[] = [];

  if (capability.operatorRetainsAuthority !== true) {
    violations.push("capability.operatorRetainsAuthority must remain true.");
  }

  if (capability.requiresPermissionModel !== true) {
    violations.push("capability.requiresPermissionModel must remain true.");
  }

  if (
    capability.executionImpact !== "none" &&
    capability.role === "system"
  ) {
    violations.push("system role capabilities may not imply execution-impacting authority.");
  }

  return {
    ok: violations.length === 0,
    violations,
  };
}

export function verifyGovernanceInvariants(): GovernanceVerificationResult {
  const violations: string[] = [];

  if (!WORKER_GOVERNANCE_INVARIANT.includes("do not possess decision authority")) {
    violations.push("worker governance invariant text drift detected.");
  }

  if (
    !PERMISSION_GOVERNANCE_INVARIANT.includes(
      "never transfer decision authority away from the human operator",
    )
  ) {
    violations.push("permission governance invariant text drift detected.");
  }

  if (
    !CAPABILITY_GOVERNANCE_INVARIANT.includes(
      "never grant autonomous decision authority",
    )
  ) {
    violations.push("capability governance invariant text drift detected.");
  }

  return {
    ok: violations.length === 0,
    violations,
  };
}

export function verifyGovernanceModel(
  worker: WorkerDefinition,
  permission: PermissionDefinition,
  capability: CapabilityDefinition,
): GovernanceVerificationResult {
  const violations: string[] = [];

  const workerCheck = verifyWorkerDefinition(worker);
  const permissionCheck = verifyPermissionDefinition(permission);
  const capabilityCheck = verifyCapabilityDefinition(capability);
  const invariantCheck = verifyGovernanceInvariants();

  violations.push(
    ...workerCheck.violations.map((v) => `worker: ${v}`),
    ...permissionCheck.violations.map((v) => `permission: ${v}`),
    ...capabilityCheck.violations.map((v) => `capability: ${v}`),
    ...invariantCheck.violations.map((v) => `invariant: ${v}`),
  );

  if (
    worker.type === "execution" &&
    capability.executionImpact === "restricted"
  ) {
    violations.push(
      "execution workers may not be paired with restricted execution-impact capabilities at this phase.",
    );
  }

  if (
    permission.role === "worker" &&
    capability.role !== "worker"
  ) {
    violations.push("worker permission must align with worker capability role.");
  }

  return {
    ok: violations.length === 0,
    violations,
  };
}
