/**
 * Effie Launcher – Final Dynamic Import Fix
 * Supports folder names with spaces or underscores
 */
import path from "path";
import { pathToFileURL } from "url";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// ✅ Resolve paths dynamically
const mirrorAgentPath = pathToFileURL(path.resolve(__dirname, "../../../mirror/agent.ts")).href;
const effiePath = pathToFileURL(path.resolve(__dirname, "../../agents/effie.ts")).href;

console.log("Effie> Loading from", mirrorAgentPath, effiePath);

const { createAgentRuntime } = await import(mirrorAgentPath);
const { effie } = await import(effiePath);

createAgentRuntime(effie);
