import { deriveAttentionLevel } from "./deriveAttentionLevel.ts";
import {
  SituationCategory,
  SituationSeverity,
  type SituationClassification,
} from "./situation.types.ts";
import type { SituationFrame } from "./situationFrame.types.ts";

function buildTitle(classification: SituationClassification): string {
  const { category, severity } = classification;

  if (severity === SituationSeverity.CRITICAL) {
    switch (category) {
      case SituationCategory.HEALTH:
        return "Critical System Health Risk";
      case SituationCategory.PERFORMANCE:
        return "Critical Performance Risk";
      case SituationCategory.RISK:
        return "Critical Operational Risk";
      case SituationCategory.INFO:
      default:
        return "Critical Situation Detected";
    }
  }

  if (severity === SituationSeverity.WARNING) {
    switch (category) {
      case SituationCategory.HEALTH:
        return "System Health Warning";
      case SituationCategory.PERFORMANCE:
        return "Performance Warning";
      case SituationCategory.RISK:
        return "Operational Risk Warning";
      case SituationCategory.INFO:
      default:
        return "Situation Warning";
    }
  }

  switch (category) {
    case SituationCategory.HEALTH:
      return "System Health Stable";
    case SituationCategory.PERFORMANCE:
      return "Performance Status Stable";
    case SituationCategory.RISK:
      return "Risk Status Informational";
    case SituationCategory.INFO:
    default:
      return "Situation Informational";
  }
}

function buildSummary(classification: SituationClassification): string {
  const { category, severity, confidence } = classification;

  if (severity === SituationSeverity.CRITICAL) {
    switch (category) {
      case SituationCategory.HEALTH:
        return `System health signals indicate a critical condition with ${confidence.toLowerCase()} confidence.`;
      case SituationCategory.PERFORMANCE:
        return `Performance signals indicate a critical degradation with ${confidence.toLowerCase()} confidence.`;
      case SituationCategory.RISK:
        return `Operational risk signals indicate a critical condition with ${confidence.toLowerCase()} confidence.`;
      case SituationCategory.INFO:
      default:
        return `Situation signals indicate a critical condition with ${confidence.toLowerCase()} confidence.`;
    }
  }

  if (severity === SituationSeverity.WARNING) {
    switch (category) {
      case SituationCategory.HEALTH:
        return `System health signals indicate a warning condition with ${confidence.toLowerCase()} confidence.`;
      case SituationCategory.PERFORMANCE:
        return `Performance signals indicate a warning condition with ${confidence.toLowerCase()} confidence.`;
      case SituationCategory.RISK:
        return `Operational risk signals indicate a warning condition with ${confidence.toLowerCase()} confidence.`;
      case SituationCategory.INFO:
      default:
        return `Situation signals indicate a warning condition with ${confidence.toLowerCase()} confidence.`;
    }
  }

  switch (category) {
    case SituationCategory.HEALTH:
      return `System health signals are informational with ${confidence.toLowerCase()} confidence.`;
    case SituationCategory.PERFORMANCE:
      return `Performance signals are informational with ${confidence.toLowerCase()} confidence.`;
    case SituationCategory.RISK:
      return `Operational risk signals are informational with ${confidence.toLowerCase()} confidence.`;
    case SituationCategory.INFO:
    default:
      return `Situation signals are informational with ${confidence.toLowerCase()} confidence.`;
  }
}

function deriveOrderHint(classification: SituationClassification): number {
  switch (classification.severity) {
    case SituationSeverity.CRITICAL:
      return 100;
    case SituationSeverity.WARNING:
      return 200;
    case SituationSeverity.INFO:
    default:
      return 300;
  }
}

export function frameSituation(
  classification: SituationClassification,
  context?: Record<string, unknown>
): SituationFrame {
  return {
    classification,
    title: buildTitle(classification),
    summary: buildSummary(classification),
    context,
    attentionLevel: deriveAttentionLevel(classification.severity),
    orderHint: deriveOrderHint(classification),
  };
}
