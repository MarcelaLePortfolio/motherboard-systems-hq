import { writeChainState } from "../_local/utils/chainState.ts";
import { log } from "../utils/log.ts";

/**
 * Matilda will delegate one task at a time by writing to agent_chain_state.json
 */
export async function matildaTaskRunner(task: any) {
  await log("Matilda received task:", task);

  // Validate task shape
  if (!task?.type) {
    return { status: "error", message: "Missing task type" };
  }

  const state = {
    agent: "Cade",
    status: "Assigned",
    type: task.type,
    package: task.package,
    message: task.message,
    command: task.command,
    ts: Date.now()
  };

  await writeChainState(state);
  await log("📨 Matilda delegated to Cade:", state);

  return { status: "delegated", to: "Cade", summary: state };
}

/**
 * Named export for Matilda agent
 */
export const matilda = {
  name: "Matilda",
  role: "Delegation & Liaison",
  handler: matildaTaskRunner
};
