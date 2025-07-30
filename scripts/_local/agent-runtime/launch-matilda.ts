import path from "path";
import fs from "fs";
import http from "http";
import readline from "readline";

// ✅ Async IIFE to avoid top-level await crash
(async () => {
  console.log("🚀 Launching Matilda agent with heartbeat...");

  // 💚 Heartbeat server
  const matildaHeartbeatPort = 3014;
  http.createServer((req, res) => {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "online", agent: "matilda", path: req.url }));
  }).listen(matildaHeartbeatPort, () => {
    console.log(`💚 Matilda heartbeat listening on port ${matildaHeartbeatPort}`);
  });

  // 🖥️ CLI Setup
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  console.log("🤖 Matilda ready for local chat + orchestration. Type 'exit' to quit.");

  async function matildaOrchestrate(task: { description: string; steps: any[] }) {
    console.log("🎬 Simulated orchestration:", task);
    return { ok: true, steps: task.steps.length };
  }

  async function handleInput(input: string) {
    const lower = input.toLowerCase().trim();
    if (!input || lower === "exit") {
      console.log("👋 Matilda shutting down.");
      process.exit(0);
    }

    // Delegate task to Cade/Effie
    if (lower.startsWith("cade:") || lower.startsWith("effie:")) {
      const [agent] = lower.split(":");
      const task = { description: input, steps: [{ agent, command: "echo", args: { text: input } }] };
      const result = await matildaOrchestrate(task);
      console.log("🎯 Orchestration result:", result);
      return;
    }

    // Local LLM via Ollama (no API key required)
    try {
      const res = await fetch("http://127.0.0.1:11434/api/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model: "llama3", prompt: input, stream: false }),
      });
      const data = await res.json();
      console.log("💬 Matilda:", data.response?.trim() || "(no response)");
    } catch (e) {
      console.error("⚠️ Local LLM error:", e);
    }
  }

  rl.on("line", handleInput);

  // Keep Node alive for PM2
  setInterval(() => {}, 1000);
})();
