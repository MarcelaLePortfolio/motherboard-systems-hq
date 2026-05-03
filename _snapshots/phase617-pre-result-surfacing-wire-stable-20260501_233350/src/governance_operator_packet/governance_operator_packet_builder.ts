import type {
  GovernanceOperatorPacketLine,
  GovernanceOperatorPacketRecord,
  GovernanceOperatorPacketSection,
} from "./governance_operator_packet_model";
import {
  formatGovernanceOperatorPacketArtifacts,
  formatGovernanceOperatorPacketCompleteness,
  formatGovernanceOperatorPacketDecision,
  formatGovernanceOperatorPacketHeadline,
  formatGovernanceOperatorPacketInvariants,
  formatGovernanceOperatorPacketPolicy,
  formatGovernanceOperatorPacketStages,
} from "./governance_operator_packet_formatter";

export interface GovernanceOperatorPacketInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  policy_route?: string | null;
  invariants_triggered?: readonly string[];
  completed_stages?: readonly string[];
  explanation_available: boolean;
  audit_recorded: boolean;
  timestamp: number;
}

export function buildGovernanceOperatorPacket(
  input: GovernanceOperatorPacketInput,
): GovernanceOperatorPacketRecord {
  const complete = true;

  const overviewLines: GovernanceOperatorPacketLine[] = [
    { key: "decision", text: formatGovernanceOperatorPacketDecision(input.decision) },
    {
      key: "policy",
      text: formatGovernanceOperatorPacketPolicy(input.policy_route ?? null),
    },
  ];

  const evaluationLines: GovernanceOperatorPacketLine[] = [
    {
      key: "invariants",
      text: formatGovernanceOperatorPacketInvariants(
        input.invariants_triggered ?? [],
      ),
    },
    {
      key: "stages",
      text: formatGovernanceOperatorPacketStages(input.completed_stages ?? []),
    },
  ];

  const artifactLines: GovernanceOperatorPacketLine[] = [
    {
      key: "artifacts",
      text: formatGovernanceOperatorPacketArtifacts(
        input.explanation_available,
        input.audit_recorded,
      ),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorPacketCompleteness(complete),
    },
  ];

  const sections: GovernanceOperatorPacketSection[] = [
    { title: "Overview", lines: overviewLines },
    { title: "Evaluation", lines: evaluationLines },
    { title: "Artifacts", lines: artifactLines },
  ];

  return {
    headline: formatGovernanceOperatorPacketHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      packet_version: "1",
      complete,
      timestamp: input.timestamp,
    },
    sections,
  };
}
