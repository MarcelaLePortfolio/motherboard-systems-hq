import { executionGuidanceHook } from "./execution_guidance_hook.mjs";

/**
 * PHASE 622 — ATTACH POINT (NON-INTRUSIVE)
 *
 * PURPOSE:
 * - Provide a single callable entry point to attach guidance
 *   to any existing event stream (SSE, polling, or API layer)
 *
 * RULES:
 * - MUST remain passive
 * - MUST NOT mutate events
 * - MUST NOT trigger tasks
 * - SAFE to call anywhere AFTER events are produced
 */

export function attachExecutionGuidance(events = []) {
  try {
    if (!Array.isArray(events) || events.length === 0) return;

    executionGuidanceHook(events);
  } catch (err) {
    console.error('[execution-guidance] attach error', err?.message || err);
  }
}
