import { broadcastAgentUpdate } from "../../routes/eventsAgents.js";
import { getCadeStatus } from "../agents/cade.ts";
import { getMatildaStatus } from "../agents/matilda.ts";
import { getEffieStatus } from "../agents/effie.ts";

export async function emitAgentStatuses() {
  const agents = [
    { name: "Matilda", status: await getMatildaStatus() },
    { name: "Cade", status: await getCadeStatus() },
    { name: "Effie", status: await getEffieStatus() }
  ];
  broadcastAgentUpdate({ agents, time: new Date().toISOString() });
  console.log(`📡 Agent statuses broadcasted → ${agents.length} agents`);
}
