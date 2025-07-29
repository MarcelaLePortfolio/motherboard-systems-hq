import { pathToFileURL } from "url";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";

// Dynamically resolve to absolute file URL
const agentPath = pathToFileURL(resolve(process.cwd(), "src/scripts/agents/cade.ts")).href;
await import(agentPath);
