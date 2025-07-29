/**
 * Cade Launcher – Dynamic Import, Folder-Safe
 */
import path from "path";
import { pathToFileURL } from "url";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const mirrorAgentPath = pathToFileURL(path.resolve(__dirname, "../../../mirror/agent.ts")).href;
const cadePath = pathToFileURL(path.resolve(__dirname, "../../agents/cade.ts")).href;

const { createAgentRuntime } = await import(mirrorAgentPath);
const { cade } = await import(cadePath);

createAgentRuntime(cade);
