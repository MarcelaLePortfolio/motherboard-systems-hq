// Phase 663 — Guidance API with Passive History Capture

import originalHandler from "./guidance.original.mjs";
import { withGuidanceHistoryCapture } from "./_patch-guidance-with-history.mjs";

const handler = withGuidanceHistoryCapture(originalHandler);

export default handler;
