import { spawn } from "child_process";

export async function retryCreateAgent(agentName: string, maxRetries = 3, delayMs = 1000) {
  for (let i = 1; i <= maxRetries; i++) {
    console.log(`<0001fad5> Attempt ${i} to create agent: ${agentName}`);
    const result = await new Promise((resolve) => {
      const proc = spawn("node", ["scripts/run-create-atlas.js", agentName]);
      proc.on("exit", (code) => resolve(code === 0));
    });

    if (result) {
      console.log(`<0001fad6> ✅ Agent ${agentName} created successfully`);
      return true;
    }

    console.warn(`<0001fad7> ⚠️ Agent creation failed (attempt ${i}/${maxRetries})`);
    if (i < maxRetries) await new Promise((r) => setTimeout(r, delayMs));
  }

  console.error(`<0001fad8> ❌ Failed to create agent ${agentName} after ${maxRetries} attempts`);
  return false;
}
