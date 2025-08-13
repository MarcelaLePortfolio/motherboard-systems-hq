 
import { log } from "../utils/log.ts";
import { delegateToCade } from "../relay/agent-to-cade.ts";
import { delegateToEffie } from "../relay/agent-to-effie.ts";

/**
 * Full Matilda task runner implementation
 */
export async function matildaTaskRunner(task: any) {
  await log("Matilda received task:", task);

  if (!task || !task.steps) return { status: "ok", result: "No steps to run." };

  const results: any[] = [];
  for (const step of task.steps) {
    const { agent, command, args } = step;
    try {
      let result;
      if (agent === 'cade') {
        result = await delegateToCade({ command, args, sourceAgent: 'matilda' });
      } else if (agent === 'effie') {
        result = await delegateToEffie({ command, args, sourceAgent: 'matilda' });
      } else {
        throw new Error(`Unknown agent: ${agent}`);
      }
      results.push({ agent, command, result });
    } catch (err: any) {
      results.push({ agent, command, error: err.message });
    }
  }

  await log({ description: task.description || "Unnamed Matilda Task", results });
  return { status: "complete", results };
}

/**
 * Named export for Matilda agent
 */
export const matilda = {
  name: "Matilda",
  role: "Delegation & Liaison",
  handler: matildaTaskRunner
};
