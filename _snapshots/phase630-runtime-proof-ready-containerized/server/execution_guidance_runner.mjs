import { logExecutionGuidanceInterpretation } from "./execution_guidance_router.mjs";

/**
 * PHASE 621 — PASSIVE GUIDANCE RUNNER
 * - Reads task.completed events
 * - Passes them into guidance router
 * - Logs interpretation ONLY (no side effects)
 */

export function runExecutionGuidance(events = []) {
  if (!Array.isArray(events)) {
    console.warn('[execution-guidance] invalid events input');
    return;
  }

  for (const event of events) {
    if (!event) continue;

    // Strict filter: only task.completed events
    if (
      event.type === 'task.completed' ||
      event.event_type === 'task.completed'
    ) {
      logExecutionGuidanceInterpretation(event);
    }
  }
}

/**
 * Safe test harness (manual invocation only)
 */
if (process.env.GUIDANCE_TEST === 'true') {
  console.log('[execution-guidance] running in test mode');

  const mockEvents = [
    {
      type: 'task.completed',
      payload: {
        task_id: 'test-1',
        run_id: 'run-1',
        communicationResult: {
          outcome: 'success',
          explanation: 'Task completed successfully',
        },
      },
    },
    {
      type: 'task.completed',
      payload: {
        task_id: 'test-2',
        run_id: 'run-2',
        communicationResult: {
          outcome: 'failed',
          explanation: 'Temporary failure, retry recommended',
        },
      },
    },
  ];

  runExecutionGuidance(mockEvents);
}
