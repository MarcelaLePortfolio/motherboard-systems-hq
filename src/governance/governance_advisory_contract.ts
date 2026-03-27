/*
Phase 290 — Governance Advisory Layer Planning
Governance Advisory Contract (FOUNDATION)

Purpose:
Define the advisory output structure that governance modules will use
to report cognition findings to the operator layer without influencing
execution, routing, mutation, or runtime behavior.

SAFETY PROPERTIES:

Read-only
Advisory only
Deterministic
No runtime wiring
No reducers
No task interaction
No agent interaction
No execution authority
No mutation capability

This file establishes STRUCTURE ONLY.
No integrations permitted.
*/

export type GovernanceSeverity =
  | "info"
  | "notice"
  | "warning"
  | "risk"
  | "critical";

export type GovernanceDomain =
  | "authority"
  | "task_safety"
  | "agent_behavior"
  | "registry"
  | "execution_boundary"
  | "governance_integrity"
  | "cognition_reliability";

export interface GovernanceAdvisorySignal {

  /*
  Unique deterministic id
  */
  id: string;

  /*
  Classification domain
  */
  domain: GovernanceDomain;

  /*
  Severity classification
  */
  severity: GovernanceSeverity;

  /*
  Human readable explanation
  */
  summary: string;

  /*
  Deterministic explanation detail
  */
  detail: string;

  /*
  Recommended operator awareness action
  (NOT execution action)
  */
  operator_guidance: string;

  /*
  Governance reasoning trace (read-only cognition explanation)
  */
  reasoning: string;

  /*
  Detection timestamp (ISO)
  */
  detected_at: string;

  /*
  Source governance module
  */
  source: string;

  /*
  Verification state
  */
  verified: boolean;
}

/*
Advisory container (future operator surfaces)
*/

export interface GovernanceAdvisoryReport {

  generated_at: string;

  signals: GovernanceAdvisorySignal[];

  total_signals: number;

  highest_severity:
    | "info"
    | "notice"
    | "warning"
    | "risk"
    | "critical"
    | "none";
}

/*
Pure deterministic helper
No runtime coupling permitted
*/

export function deriveHighestSeverity(
  signals: GovernanceAdvisorySignal[]
): GovernanceAdvisoryReport["highest_severity"] {

  if (signals.length === 0) {
    return "none";
  }

  const order = [
    "info",
    "notice",
    "warning",
    "risk",
    "critical"
  ];

  let highest = 0;

  for (const s of signals) {
    const index = order.indexOf(s.severity);

    if (index > highest) {
      highest = index;
    }
  }

  return order[highest] as GovernanceAdvisoryReport["highest_severity"];
}

