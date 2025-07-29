import readline from "readline";
import { createAgentRuntime } from "../../../mirror/agent.js";

export const matilda = { name: "Matilda", port: 3014 };

// Start runtime for heartbeat & dashboard
createAgentRuntime(matilda);

// Basic safe command loop
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  prompt: "Matilda> "
});

console.log("🧠 Matilda v2 interactive mode ready. Type a command…");

rl.on("line", async (line) => {
  const input = line.trim().toLowerCase();

  if (!input) {
    rl.prompt();
    return;
  }

  if (input === "hello") {
    console.log("💬 Hello! Matilda is online and listening.");
  } else if (input.startsWith("say ")) {
    console.log("🗣 " + line.slice(4));
  } else if (input === "ping cade") {
    console.log("📡 Cade appears online at port 3012 ✅");
  } else if (input === "ping effie") {
    console.log("📡 Effie appears online at port 3013 ✅");
  } else {
    console.log(`🤔 I heard: "${line}" but I don't know that command yet.`);
  }

  rl.prompt();
}).on("close", () => {
  console.log("👋 Matilda shutting down...");
  process.exit(0);
});

rl.prompt();
