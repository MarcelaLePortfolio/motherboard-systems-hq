/**
 * Effie Launcher – Dynamic Import, Folder-Safe
 */
import path from "path";
import { pathToFileURL } from "url";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const mirrorAgentPath = pathToFileURL(path.resolve(__dirname, "../../../mirror/agent.ts")).href;
const effiePath = pathToFileURL(path.resolve(__dirname, "../../agents/effie.ts")).href;

const { createAgentRuntime } = await import(mirrorAgentPath);
const { effie } = await import(effiePath);

createAgentRuntime(effie);
