
/**

 * Task Event Normalizer

 * Enforcement layer for EXECUTION_VISIBILITY_CONTRACT

 *

 * This module is the single collapse boundary between:

 * - internal execution complexity

 * - UI-safe lifecycle representation

 */

const UI_STATES = new Set([

  "requested",

  "completed",

  "failed"

]);

export function collapseExecutionState(event = {}) {

  const rawStatus =

    event?.status ||

    event?.kind ||

    event?.type ||

    event?.event ||

    "";

  const normalized = String(rawStatus).toLowerCase();

  if (

    normalized.includes("completed") ||

    normalized === "done" ||

    normalized === "success"

  ) {

    return "completed";

  }

  if (

    normalized.includes("failed") ||

    normalized === "error" ||

    normalized === "cancelled" ||

    normalized === "canceled"

  ) {

    return "failed";

  }

  return "requested";

}

export function sanitizeEvent(event = {}) {

  return {

    task_id: event.task_id || event.taskId || null,

    status: collapseExecutionState(event),

    title: event.title || null,

    ts: event.ts || Date.now()

  };

}

export function enforceExecutionVisibility(event = {}) {

  const sanitized = sanitizeEvent(event);

  if (!UI_STATES.has(sanitized.status)) {

    return {

      ...sanitized,

      status: "requested"

    };

  }

  return sanitized;

}

export default {

  collapseExecutionState,

  sanitizeEvent,

  enforceExecutionVisibility

};

