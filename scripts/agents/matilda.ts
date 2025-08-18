import { createAgentRuntime } from "../mirror/agent.mjs";
import { randomUUID } from "crypto";
const matilda = "Matilda";
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

async function handleAutoWithMatilda(args: any) {
  const description = args?.description || "";

  const { cadeCommandRouter } = await import("./cade");
  const result = await cadeCommandRouter("infer agent", { description });

  if (result.status !== "success") {
    return {
      status: "error",
      message: "Cade couldn't determine the agent. Please specify directly.",
    };
  }

  const { agent, reason } = result;
  console.log(`🧠 Cade suggested: ${agent} (${reason})`);

  switch (agent) {
    case "Cade": {
      return await cadeCommandRouter("delete", { path: "backup" }); // EXAMPLE: hardcoded for now
    }
    case "Effie": {
      const { effieCommandRouter } = await import("./effie");
      return await effieCommandRouter("delete", { path: "backup" }); // EXAMPLE
    }
    case "Matilda":
      return {
        status: "info",
        message: `Matilda would handle this directly, but no handler is defined yet.`,
      };
  }
}






export async function matildaCommandRouter(command: string, args?: any) {
  switch (command) {
    case "auto": {
      return await handleAutoWithMatilda(args);
    }
    default: {
      return { status: "error", message: "Unknown command" };
    }
  }
}
