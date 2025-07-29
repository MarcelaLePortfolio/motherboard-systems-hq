import { pathToFileURL } from "url";
import { resolve } from "path";

const agentFile = resolve(process.cwd(), "src/scripts/agents/effie.ts");
console.log("🔹 Launching Effie from", agentFile);

await import(pathToFileURL(agentFile).href);
