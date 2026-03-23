/*
PHASE 89 — GUIDANCE REDUCER SCAFFOLD
Attaches bounded operator guidance generation to the health surface domain.
Cognition only. No execution authority.
*/

import type {
  GuidanceConfidence,
  OperatorGuidance,
  OperatorGuidanceEnvelope,
} from "./operatorGuidance";
import {
  mapSignalsToOperatorGuidance,
  type GuidanceMappingContext,
  type GuidanceSignalObservation,
} from "./operatorGuidanceMapping";
import { assessGuidanceConfidence } from "./operatorGuidanceConfidence";


function applyOperationalConfidencePriorityWeight(
  priority: applyOperationalConfidencePriorityWeight(number, input.operationalConfidence),
  confidence?: import("./confidence").OperationalConfidence,
): number {
  return Math.round(priority * confidencePriorityWeight(confidence));
}


export type OperatorHealthSurface = {
  signals: GuidanceSignalObservation[];
  generatedAt: number;
};

export type OperatorGuidanceReduction = {
  envelope: OperatorGuidanceEnvelope;
  surfaceConfidence: GuidanceConfidence;
  confidenceReason: string;
  signalCount: number;
  conflictingSignals: boolean;
};

function sortGuidanceDeterministically(
  guidance: OperatorGuidance[],
): OperatorGuidance[] {
  return [...guidance].sort((a, b) => {
    if (a.createdAt !== b.createdAt) {
      return a.createdAt - b.createdAt;
    }

    if (a.domain !== b.domain) {
      return a.domain.localeCompare(b.domain);
    }

    if (a.severity !== b.severity) {
      return a.severity.localeCompare(b.severity);
    }

    return a.id.localeCompare(b.id);
  });
}

export function reduceOperatorHealthSurfaceToGuidance(
  surface: OperatorHealthSurface,
  context?: Partial<GuidanceMappingContext>,
): OperatorGuidanceReduction {
  const mappingContext: GuidanceMappingContext = {
    now: context?.now ?? surface.generatedAt,
  };

  const guidance = sortGuidanceDeterministically(
    mapSignalsToOperatorGuidance(surface.signals, mappingContext),
  );

  const confidence = assessGuidanceConfidence(surface.signals);

  return {
    envelope: {
      guidance,
      generatedAt: mappingContext.now,
      cognitionVersion: "phase_89",
      executionAuthority: "none",
    },
    surfaceConfidence: confidence.confidence,
    confidenceReason: confidence.reason,
    signalCount: confidence.signalCount,
    conflictingSignals: confidence.conflictingSignals,
  };
}

export function createEmptyOperatorGuidanceReduction(
  generatedAt: number,
): OperatorGuidanceReduction {
  return {
    envelope: {
      guidance: [],
      generatedAt,
      cognitionVersion: "phase_89",
      executionAuthority: "none",
    },
    surfaceConfidence: "insufficient",
    confidenceReason: "No signals available for interpretation.",
    signalCount: 0,
    conflictingSignals: false,
  };
}
