import { runExecutionGuidance } from "../execution_guidance_runner.mjs";

/**
 * PHASE 621 — SAFE INTEGRATION HOOK
 *
 * PURPOSE:
 * - Accept a batch of events (already fetched elsewhere)
 * - Pass into guidance runner
 *
 * RULES:
 * - NO side effects
 * - NO task triggering
 * - NO DB writes
 * - PURELY observational
 */

export function executionGuidanceHook(events = []) {
  try {
    runExecutionGuidance(events);
  } catch (err) {
    console.error('[execution-guidance] hook error', err?.message || err);
  }
}
