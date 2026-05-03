import type {
  GovernanceReportRecord,
  GovernanceReportSection,
} from "./governance_reporting_model";
import {
  formatGovernanceReportDecision,
  formatGovernanceReportHeadline,
  formatGovernanceReportInvariants,
  formatGovernanceReportPolicy,
  formatGovernanceReportProvenance,
  formatGovernanceReportStages,
} from "./governance_reporting_formatter";

export interface GovernanceReportingInput {
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

export function buildGovernanceReport(
  input: GovernanceReportingInput,
): GovernanceReportRecord {
  const provenanceSummary =
    input.provenance_summary ?? "deterministic governance path";

  const sections: GovernanceReportSection[] = [
    {
      title: "Decision Summary",
      lines: [
        { label: "decision", value: formatGovernanceReportDecision(input.decision) },
        {
          label: "policy",
          value: formatGovernanceReportPolicy(input.policy_route ?? null),
        },
      ],
    },
    {
      title: "Evaluation Summary",
      lines: [
        {
          label: "invariants",
          value: formatGovernanceReportInvariants(
            input.invariants_triggered ?? [],
          ),
        },
        {
          label: "stages",
          value: formatGovernanceReportStages(input.completed_stages ?? []),
        },
      ],
    },
    {
      title: "Artifact Summary",
      lines: [
        {
          label: "explanation",
          value: `Explanation available: ${input.explanation_available ? "yes" : "no"}`,
        },
        {
          label: "audit",
          value: `Audit recorded: ${input.audit_recorded ? "yes" : "no"}`,
        },
        {
          label: "provenance",
          value: formatGovernanceReportProvenance(provenanceSummary),
        },
      ],
    },
  ];

  return {
    decision_id: input.decision_id,
    headline: formatGovernanceReportHeadline(input.decision_id, input.decision),
    sections,
    timestamp: input.timestamp,
  };
}
