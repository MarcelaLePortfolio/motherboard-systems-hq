import { createAgentRuntime } from "../../mirror/agent";
import { cade } from "../../agents/cade";
import fs from "fs";

createAgentRuntime(cade);

try {
  fs.appendFileSync(
    "ui/dashboard/ticker-events.log",
    `{"timestamp":"${Math.floor(Date.now()/1000)}","agent":"cade","event":"agent-online"}\n`
  );
  console.log("🟢 Cade ticker event emitted: agent-online");
} catch (err) {
  console.error("❌ Failed to emit Cade ticker event:", err);
}
