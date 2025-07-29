import { pathToFileURL } from "url";
import { resolve } from "path";

const agentFile = resolve(process.cwd(), "src/scripts/agents/matilda.ts");
console.log("🔹 Launching Matilda from", agentFile);

await import(pathToFileURL(agentFile).href);
