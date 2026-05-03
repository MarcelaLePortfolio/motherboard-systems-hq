import { executionGuidanceHook } from "./execution_guidance_hook.mjs";

/**
 * PHASE 621 — DEV PROBE (REALISTIC EVENT SHAPE)
 * - Simulates real task.completed events
 * - Passes through hook → runner → router
 * - Validates end-to-end wiring of guidance layer
 */

const simulatedEvents = [
  {
    type: 'task.completed',
    payload: {
      task_id: 'dev-1',
      run_id: 'run-101',
      communicationResult: {
        outcome: 'success',
        explanation: 'Execution completed successfully',
      },
    },
  },
  {
    type: 'task.completed',
    payload: {
      task_id: 'dev-2',
      run_id: 'run-102',
      communicationResult: {
        outcome: 'failed',
        explanation: 'Temporary failure, retry recommended',
      },
    },
  },
  {
    type: 'task.completed',
    payload: {
      task_id: 'dev-3',
      run_id: 'run-103',
      communicationResult: {
        outcome: 'blocked',
        explanation: 'Missing required input, cannot proceed',
      },
    },
  },
];

console.log("▶️ Running execution guidance dev probe...\n");

executionGuidanceHook(simulatedEvents);

console.log("\n✅ Expect classifications: success / retryable / blocked");
