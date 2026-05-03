import type {
  GovernanceDigestLine,
  GovernanceDigestRecord,
} from "./governance_digest_model";
import {
  formatGovernanceDigestArtifacts,
  formatGovernanceDigestDecision,
  formatGovernanceDigestHeadline,
  formatGovernanceDigestInvariants,
  formatGovernanceDigestPolicy,
  formatGovernanceDigestProvenance,
  formatGovernanceDigestStages,
} from "./governance_digest_formatter";

export interface GovernanceDigestInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  policy_route?: string | null;
  invariants_triggered?: readonly string[];
  completed_stages?: readonly string[];
  explanation_available: boolean;
  audit_recorded: boolean;
  provenance_summary?: string;
  timestamp: number;
}

export function buildGovernanceDigest(
  input: GovernanceDigestInput,
): GovernanceDigestRecord {
  const provenanceSummary =
    input.provenance_summary ?? "deterministic governance path";

  const lines: GovernanceDigestLine[] = [
    {
      key: "decision",
      text: formatGovernanceDigestDecision(input.decision),
    },
    {
      key: "policy",
      text: formatGovernanceDigestPolicy(input.policy_route ?? null),
    },
    {
      key: "invariants",
      text: formatGovernanceDigestInvariants(input.invariants_triggered ?? []),
    },
    {
      key: "stages",
      text: formatGovernanceDigestStages(input.completed_stages ?? []),
    },
    {
      key: "artifacts",
      text: formatGovernanceDigestArtifacts(
        input.explanation_available,
        input.audit_recorded,
      ),
    },
    {
      key: "provenance",
      text: formatGovernanceDigestProvenance(provenanceSummary),
    },
  ];

  return {
    decision_id: input.decision_id,
    headline: formatGovernanceDigestHeadline(input.decision_id, input.decision),
    lines,
    timestamp: input.timestamp,
  };
}
