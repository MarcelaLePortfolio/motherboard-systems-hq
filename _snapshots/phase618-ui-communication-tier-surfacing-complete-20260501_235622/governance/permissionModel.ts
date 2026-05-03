/*
Phase 96.3 — Permission Governance Model

Purpose:
Define explicit permission structure across operator, system, and worker roles.

This file introduces structural clarity only.
No runtime behavior is modified.

Doctrine alignment:
Human decides.
System informs.
Automation executes bounded work.
*/

export type GovernanceRole =
  | "operator"
  | "worker"
  | "system"
  | (string & {}); // future-expandable

export type PermissionAuthority =
  | "full"
  | "bounded"
  | "none";

export type PermissionGrantSource =
  | "human_operator"
  | "policy_layer"
  | "system_default"
  | "none"
  | (string & {}); // future-expandable

export type PermissionConstraint =
  | "no_self_authorization"
  | "bounded_execution_only"
  | "governance_immutable"
  | "operator_override_required"
  | (string & {}); // future-expandable

export interface PermissionDefinition {
  id: string;

  /*
  Which governance role this permission definition applies to.
  */
  role: GovernanceRole;

  /*
  Level of authority available to the role.
  */
  authority: PermissionAuthority;

  /*
  Where any execution allowance originates.
  */
  grantSource: PermissionGrantSource;

  /*
  Structural constraints that remain in force.
  */
  constraints: PermissionConstraint[];

  /*
  Permissions never transfer operator authority to automation.
  */
  operatorRetainsAuthority: true;
}

/*
Baseline governance invariant:
Permissions may describe bounded authority,
but they never allow automation to self-authorize.
*/
export const PERMISSION_GOVERNANCE_INVARIANT =
  "Permissions may describe bounded authority but never transfer decision authority away from the human operator.";

