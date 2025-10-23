import { emitAgentStatuses } from "./emitAgentUpdate.ts";

setInterval(async () => {
  await emitAgentStatuses();
}, 10000); // every 10 seconds

console.log("🔁 Auto-broadcasting agent statuses every 10 seconds...");
