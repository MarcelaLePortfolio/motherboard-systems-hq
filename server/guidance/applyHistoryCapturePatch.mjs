// Phase 663 — Safe Integration Patch (NON-MUTATING)

// NOTE:
// This patch assumes guidance is emitted through a central function.
// If your project uses a different emitter, adjust the import target only.
// DO NOT change payload structure or execution flow.

import { captureGuidanceSnapshot } from "./_wireHistoryCapture.mjs";

// Example patch function — wrap existing emitter
export function withHistoryCapture(originalEmitter) {
  return function wrappedEmitter(payload) {
    const observed = captureGuidanceSnapshot(payload);
    return originalEmitter(observed);
  };
}
