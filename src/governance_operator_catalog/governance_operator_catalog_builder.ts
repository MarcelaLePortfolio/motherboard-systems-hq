import type {
  GovernanceOperatorCatalogLine,
  GovernanceOperatorCatalogRecord,
} from "./governance_operator_catalog_model";
import {
  formatGovernanceOperatorCatalogCompleteness,
  formatGovernanceOperatorCatalogDecision,
  formatGovernanceOperatorCatalogHeadline,
  formatGovernanceOperatorCatalogReadiness,
  formatGovernanceOperatorCatalogSections,
  formatGovernanceOperatorCatalogVersion,
} from "./governance_operator_catalog_formatter";

export interface GovernanceOperatorCatalogInput {
  decision_id: string;
  decision: "ALLOW" | "WARN" | "BLOCK";
  section_titles?: readonly string[];
  timestamp: number;
}

export function buildGovernanceOperatorCatalog(
  input: GovernanceOperatorCatalogInput,
): GovernanceOperatorCatalogRecord {
  const ready = true;
  const complete = true;
  const catalogVersion = "1";

  const lines: GovernanceOperatorCatalogLine[] = [
    {
      key: "decision",
      text: formatGovernanceOperatorCatalogDecision(input.decision),
    },
    {
      key: "sections",
      text: formatGovernanceOperatorCatalogSections(input.section_titles ?? []),
    },
    {
      key: "ready",
      text: formatGovernanceOperatorCatalogReadiness(ready),
    },
    {
      key: "complete",
      text: formatGovernanceOperatorCatalogCompleteness(complete),
    },
    {
      key: "version",
      text: formatGovernanceOperatorCatalogVersion(catalogVersion),
    },
  ];

  return {
    headline: formatGovernanceOperatorCatalogHeadline(
      input.decision_id,
      input.decision,
    ),
    metadata: {
      decision_id: input.decision_id,
      catalog_version: catalogVersion,
      ready,
      complete,
      timestamp: input.timestamp,
    },
    lines,
  };
}
