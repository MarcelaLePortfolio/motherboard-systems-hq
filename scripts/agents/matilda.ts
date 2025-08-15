import { matilda } from "../../agents/matilda";
import { createAgentRuntime } from "../../mirror/agent.mjs";
import { writeChainState } from "../utils/chainState";
import { randomUUID } from "crypto";

createAgentRuntime(matilda, async (input: string) => {
  const task = {
    agent: "Cade",
    status: "Assigned",
    type: "debug",
    content: input,
    ts: Date.now(),
    uuid: randomUUID()
  };

  await writeChainState(task);

  return `📤 Delegated task to Cade.\n\n🕰️ Waiting for result... (Check Cade logs)`;
});
