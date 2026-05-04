// Phase 663 — Controlled Integration (GUIDANCE API ONLY)

// IMPORTANT:
// - This wraps ONLY the guidance API response
// - Does NOT touch execution, worker, or SSE
// - Zero mutation to payload structure

import { captureGuidanceSnapshot } from "../guidance/_wireHistoryCapture.mjs";

export function withGuidanceHistoryCapture(originalHandler) {
  return async function wrappedHandler(req, res) {
    const originalJson = res.json.bind(res);

    res.json = (payload) => {
      try {
        captureGuidanceSnapshot(payload);
      } catch (e) {
        // silent fail — no risk
      }

      return originalJson(payload);
    };

    return originalHandler(req, res);
  };
}
