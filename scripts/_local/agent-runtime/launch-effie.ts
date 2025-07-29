import { pathToFileURL } from "url";
import { resolve } from "path";

const agentPath = pathToFileURL(resolve(process.cwd(), "src/scripts/agents/effie.ts")).href;
await import(agentPath);
