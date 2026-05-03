import type { OperatorAcknowledgement } from "./operatorAcknowledgement.types.ts";
import type { OperatorAttention } from "./operatorAttention.types.ts";
import type { OperatorHistoryEntry } from "./operatorHistory.types.ts";
import type { OperatorInteractionOutput } from "./operatorInteractionOutput.types.ts";
import type { OperatorSurface } from "./operatorSurface.types.ts";
import type { OperatorWorkflowState } from "./operatorWorkflow.types.ts";

function stableStringArray(values: string[]): string[] {
  return [...values].map((value) => value.trim()).filter(Boolean);
}

function normalizeSurface(surface: OperatorSurface): OperatorSurface {
  return {
    ...surface,
    title: surface.title.trim(),
    explanation: surface.explanation.trim(),
    actionMessage: surface.actionMessage.trim(),
    recommendedSteps: stableStringArray(surface.recommendedSteps),
    prohibitedSteps: stableStringArray(surface.prohibitedSteps),
  };
}

function normalizeAcknowledgement(
  acknowledgement: OperatorAcknowledgement
): OperatorAcknowledgement {
  return {
    surfaceId: acknowledgement.surfaceId,
    acknowledged: acknowledgement.acknowledged,
    acknowledgedAt: acknowledgement.acknowledgedAt,
    acknowledgedBy: acknowledgement.acknowledgedBy,
  };
}

function normalizeAttention(attention: OperatorAttention): OperatorAttention {
  return {
    level: attention.level,
    badge: attention.badge.trim(),
    emphasis: attention.emphasis,
  };
}

function normalizeWorkflow(workflow: OperatorWorkflowState): OperatorWorkflowState {
  return {
    surface: normalizeSurface(workflow.surface),
    attention: normalizeAttention(workflow.attention),
    acknowledgement: normalizeAcknowledgement(workflow.acknowledgement),
    requiresAction: workflow.requiresAction,
    readyForAutomation: workflow.readyForAutomation,
  };
}

function compareHistory(a: OperatorHistoryEntry, b: OperatorHistoryEntry): number {
  if (a.recordedAt !== b.recordedAt) {
    return a.recordedAt - b.recordedAt;
  }

  return a.surface.id.localeCompare(b.surface.id);
}

function normalizeHistoryEntry(entry: OperatorHistoryEntry): OperatorHistoryEntry {
  return {
    surface: normalizeSurface(entry.surface),
    attention: normalizeAttention(entry.attention),
    acknowledgement: normalizeAcknowledgement(entry.acknowledgement),
    recordedAt: entry.recordedAt,
  };
}

export function composeOperatorInteractionOutput(args: {
  surface: OperatorSurface;
  attention: OperatorAttention;
  acknowledgement: OperatorAcknowledgement;
  workflow: OperatorWorkflowState;
  history: OperatorHistoryEntry[];
}): OperatorInteractionOutput {
  return {
    surface: normalizeSurface(args.surface),
    attention: normalizeAttention(args.attention),
    acknowledgement: normalizeAcknowledgement(args.acknowledgement),
    workflow: normalizeWorkflow(args.workflow),
    history: [...args.history].map(normalizeHistoryEntry).sort(compareHistory),
  };
}
