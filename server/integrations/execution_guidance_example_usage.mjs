import { attachExecutionGuidance } from "./execution_guidance_attach_point.mjs";

/**
 * EXAMPLE USAGE — DO NOT AUTO-WIRE
 *
 * This file demonstrates how to safely attach execution guidance
 * AFTER events are already fetched from an existing source.
 *
 * Replace `fetchEvents()` with your real event retrieval logic.
 */

async function fetchEvents() {
  // Placeholder: replace with real DB / SSE / API read
  return [];
}

export async function runGuidanceOnLiveEvents() {
  const events = await fetchEvents();

  // SAFE: read-only interpretation
  attachExecutionGuidance(events);
}

// Manual invocation only
if (process.env.RUN_GUIDANCE === 'true') {
  runGuidanceOnLiveEvents();
}
