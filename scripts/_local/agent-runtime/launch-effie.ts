/**
 * Effie Launcher – Dynamic Import Fix
 */
import path from "path";
import { pathToFileURL } from "url";
import { fileURLToPath } from "url";

// Resolve mirror/agent.ts dynamically for TSX + ESM
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const mirrorAgentPath = pathToFileURL(path.resolve(__dirname, "../../../mirror/agent.ts")).href;

const { createAgentRuntime } = await import(mirrorAgentPath);
const { effie } = await import("../../agents/effie.ts");

createAgentRuntime(effie);
