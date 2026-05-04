// Phase 663 — Guidance API (WITH HISTORY CAPTURE APPLIED)

import originalHandler from "./guidance.original.mjs";
import { withGuidanceHistoryCapture } from "./_patch-guidance-with-history.mjs";

// Apply wrapper (non-mutating)
const handler = withGuidanceHistoryCapture(originalHandler);

export default handler;
