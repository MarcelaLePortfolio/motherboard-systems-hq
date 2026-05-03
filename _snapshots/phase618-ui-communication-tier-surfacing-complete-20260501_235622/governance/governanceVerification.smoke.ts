/*
Phase 96.5 — Governance Verification Smoke

Deterministic proof scaffold for governance contracts.
No runtime behavior is modified.
*/

import { verifyGovernanceModel } from "./governanceVerification";
import type { WorkerDefinition } from "./workerModel";
import type { PermissionDefinition } from "./permissionModel";
import type { CapabilityDefinition } from "./capabilityModel";

function assert(condition: unknown, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

const worker: WorkerDefinition = {
  id: "worker.execution.default",
  type: "execution",
  authority: "bounded_execution",
  requiresPolicyGrant: true,
  governanceImpact: "none",
  operatorOverride: true,
};

const permission: PermissionDefinition = {
  id: "permission.worker.default",
  role: "worker",
  authority: "bounded",
  grantSource: "policy_layer",
  constraints: [
    "no_self_authorization",
    "bounded_execution_only",
    "governance_immutable",
    "operator_override_required",
  ],
  operatorRetainsAuthority: true,
};

const capability: CapabilityDefinition = {
  id: "capability.worker.process_bounded_task",
  capability: "process_bounded_task",
  role: "worker",
  executionImpact: "bounded",
  requiresPermissionModel: true,
  operatorRetainsAuthority: true,
  description: "Allows bounded task processing under policy constraints.",
};

export function runGovernanceVerificationSmoke(): void {
  const result = verifyGovernanceModel(worker, permission, capability);

  assert(result.ok === true, `governance verification failed: ${result.violations.join(" | ")}`);
  assert(result.violations.length === 0, "governance verification returned unexpected violations");
}

if (import.meta.url === `file://${process.argv[1]}`) {
  runGovernanceVerificationSmoke();
  process.stdout.write("governance verification smoke passed\n");
}
