import { attachExecutionGuidance } from "./execution_guidance_attach_point.mjs";

/**
 * PHASE 623 — WIRING STUB (NOT ACTIVE)
 *
 * PURPOSE:
 * - Define EXACT safe insertion point for guidance
 * - Document where it belongs in execution flow
 *
 * RULES:
 * - DO NOT AUTO-EXECUTE
 * - DO NOT MODIFY EVENTS
 * - DO NOT TRIGGER TASKS
 * - ONLY CALL AFTER EVENTS ARE READ (DB / SSE / API)
 *
 * INTEGRATION CONTRACT:
 *
 * Wherever events are already fetched:
 *
 *   const events = await getEvents();
 *   attachExecutionGuidance(events);  // <-- SAFE INSERTION POINT
 *
 */

export function __DO_NOT_CALL_AUTOMATICALLY__example(events = []) {
  attachExecutionGuidance(events);
}
