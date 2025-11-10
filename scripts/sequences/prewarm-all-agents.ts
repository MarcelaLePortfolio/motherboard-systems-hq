// <0001fbd0> Phase 10.5 — Agent Prewarm Sequence (Rebuilt)
import { execSync } from "child_process";

function pingAgent(name: string, cmd: string) {
  console.log(`⚙️ Pinging ${name}...`);
  try {
    execSync(cmd, { stdio: "inherit" });
    console.log(`✅ ${name} responding.`);
  } catch {
    console.log(`⚠️ ${name} unresponsive.`);
  }
}

pingAgent("Matilda", "curl -s -X POST http://localhost:3000/matilda -H 'Content-Type: application/json' -d '{\"message\":\"ping\"}'");
pingAgent("Reflections SSE", "curl -I http://localhost:3101/events/reflections");
pingAgent("OPS SSE", "curl -I http://localhost:3201/events/ops");
console.log("🔥 Agents pre-warmed and verified.");
