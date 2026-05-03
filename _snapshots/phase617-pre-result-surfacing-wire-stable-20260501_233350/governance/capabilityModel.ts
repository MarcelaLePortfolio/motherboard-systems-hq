/*
Phase 96.4 — Capability Governance Model

Purpose:
Define explicit capability structure for operator, system, and worker roles.

This file introduces structural clarity only.
No runtime behavior is modified.

Doctrine alignment:
Human decides.
System informs.
Automation executes bounded work.
*/

import type { GovernanceRole } from "./permissionModel";

export type SystemCapability =
  | "observe_system_health"
  | "view_operator_guidance"
  | "interpret_cognition_signals"
  | "process_bounded_task"
  | "request_execution"
  | "evaluate_policy"
  | "apply_policy_gate"
  | "read_runtime_state"
  | "emit_runtime_signal"
  | (string & {}); // future-expandable

export type CapabilityExecutionImpact =
  | "none"
  | "bounded"
  | "restricted";

export interface CapabilityDefinition {
  id: string;

  /*
  Explicit named capability.
  */
  capability: SystemCapability;

  /*
  Which governance role can hold this capability.
  */
  role: GovernanceRole;

  /*
  Whether this capability can affect execution.
  */
  executionImpact: CapabilityExecutionImpact;

  /*
  Capabilities do not self-authorize.
  */
  requiresPermissionModel: true;

  /*
  Human authority remains primary.
  */
  operatorRetainsAuthority: true;

  description: string;
}

/*
Baseline governance invariant:
Capabilities describe what a role may be structured to do,
but never grant autonomous decision authority.
*/
export const CAPABILITY_GOVERNANCE_INVARIANT =
  "Capabilities describe structured system function but never grant autonomous decision authority.";

