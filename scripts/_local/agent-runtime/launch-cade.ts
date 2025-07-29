import { pathToFileURL } from "url";
import { resolve } from "path";

const agentFile = resolve(process.cwd(), "src/scripts/agents/cade.ts");
console.log("🔹 Launching Cade from", agentFile);

await import(pathToFileURL(agentFile).href);
