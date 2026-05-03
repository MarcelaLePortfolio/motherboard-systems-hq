/*
Phase 96.2 — Worker Governance Model

Purpose:
Define what a Worker is within the system governance structure.

This file introduces structural clarity only.
No runtime behavior is modified.

Doctrine alignment:
Human decides.
System informs.
Automation executes bounded work.
*/

export type WorkerType =
  | "execution"
  | "cognition"
  | "system"
  | (string & {}); // future-expandable

export type WorkerAuthority =
  | "none"
  | "bounded_execution"
  | "observation_only";

export interface WorkerDefinition {
  id: string;

  /*
  Worker classification.
  Future expandable without refactor.
  */
  type: WorkerType;

  /*
  What level of authority this worker operates under.
  Workers never have operator authority.
  */
  authority: WorkerAuthority;

  /*
  Workers cannot self-authorize execution.
  */
  requiresPolicyGrant: boolean;

  /*
  Workers cannot change governance.
  */
  governanceImpact: "none";

  /*
  Human operator remains authority.
  */
  operatorOverride: true;
}

/*
Baseline governance invariant:
Workers are execution actors, not decision authorities.
*/

export const WORKER_GOVERNANCE_INVARIANT =
  "Workers execute bounded work but do not possess decision authority.";

