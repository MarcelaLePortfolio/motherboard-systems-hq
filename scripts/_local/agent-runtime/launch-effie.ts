import { createAgentRuntime } from "../../mirror/agent";
import { effie } from "../../agents/effie";
import fs from "fs";

createAgentRuntime(effie);

try {
  fs.appendFileSync(
    "ui/dashboard/ticker-events.log",
    `{"timestamp":"${Math.floor(Date.now()/1000)}","agent":"effie","event":"agent-online"}\n`
  );
  console.log("🟢 Effie ticker event emitted: agent-online");
} catch (err) {
  console.error("❌ Failed to emit Effie ticker event:", err);
}
