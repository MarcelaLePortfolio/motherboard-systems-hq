// <0001fad9> Phase 9.4.1 — Atlas Live Build & Registration
import fs from "fs";
import path from "path";
import { execSync } from "child_process";

const agentName = "atlas";
const agentsDir = path.join(process.cwd(), "agents");
const agentFile = path.join(agentsDir, `${agentName}.ts`);
const reflectionsDir = path.join(process.cwd(), "logs", "reflections");

function logReflection(message: string) {
  const timestamp = new Date().toISOString();
  const entry = { timestamp, message };
  fs.mkdirSync(reflectionsDir, { recursive: true });
  fs.appendFileSync(
    path.join(reflectionsDir, `${agentName}.log`),
    JSON.stringify(entry) + "\n"
  );
  console.log("🪞", message);
}

async function createAtlas() {
  logReflection("Matilda initializing Atlas creation protocol...");
  fs.mkdirSync(agentsDir, { recursive: true });

  // Step 1 — Generate basic agent source
  const template = `
// Auto-generated agent — Atlas
import { createAgentRuntime } from "../mirror/agent";
export const atlas = {
  id: "${agentName}",
  role: "Expansion Core",
  description: "Experimental self-extending agent under Matilda’s supervision."
};
createAgentRuntime(atlas);
`;
  fs.writeFileSync(agentFile, template.trim() + "\n");
  logReflection("Cade has built the Atlas agent source file.");

  // Step 2 — PM2 registration
  try {
    execSync(
      `pm2 start scripts/_local/agent-runtime/launch-${agentName}.ts --name ${agentName} --interpreter $(which tsx)`,
      { stdio: "inherit" }
    );
    execSync("pm2 save", { stdio: "inherit" });
    logReflection("Effie registered Atlas with PM2 and saved state.");
  } catch (err) {
    logReflection("⚠️ PM2 registration failed: " + (err as Error).message);
    process.exit(1);
  }

  // Step 3 — Final confirmation
  logReflection("✨ Atlas Online. All systems nominal.");
}

createAtlas().catch((err) => {
  console.error("❌ Atlas build failed:", err);
  logReflection("❌ Atlas build encountered an error: " + err.message);
  process.exit(1);
});
