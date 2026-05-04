// Phase 663 — History Capture Wiring (SAFE, NON-MUTATING)

import { addGuidanceSnapshot } from "./historyBuffer.mjs";

/**
 * Wrap guidance emitter safely.
 * Does NOT modify payload, only observes.
 */
export function captureGuidanceSnapshot(guidancePayload) {
  try {
    addGuidanceSnapshot(guidancePayload);
  } catch (e) {
    // silent fail — zero risk to pipeline
  }

  return guidancePayload;
}
