/**
 * Cade Launcher – Final Dynamic Import Fix
 * Supports folder names with spaces or underscores
 */
import path from "path";
import { pathToFileURL } from "url";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// ✅ Resolve paths dynamically
const mirrorAgentPath = pathToFileURL(path.resolve(__dirname, "../../../mirror/agent.ts")).href;
const cadePath = pathToFileURL(path.resolve(__dirname, "../../agents/cade.ts")).href;

console.log("Cade> Loading from", mirrorAgentPath, cadePath);

const { createAgentRuntime } = await import(mirrorAgentPath);
const { cade } = await import(cadePath);

createAgentRuntime(cade);
