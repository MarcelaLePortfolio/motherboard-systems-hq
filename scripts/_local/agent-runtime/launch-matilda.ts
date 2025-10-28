console.log("<0001f9ef> [Matilda] Launch script entered (CJS-safe + correct path).");

Promise.all([
  import("../../mirror/agent.mjs"),
  import("../../agents/matilda/matilda.mjs"),
])
  .then(async ([agentMod, matildaMod]) => {
    console.log("✅ [Matilda] Core modules loaded.");

    const { createAgentRuntime } = agentMod;
    const { matilda } = matildaMod;

    try {
      const proc = await import("../utils/matilda_task_processor.ts").catch(() => null);
      const start = proc?.startMatildaTaskProcessor || proc?.default;

      if (typeof start === "function") {
        console.log("⚙️ [Matilda] Starting Matilda Task Processor...");
        await start();
      } else {
        console.log("⚙️ [Matilda] No task processor found — starting runtime.");
        createAgentRuntime(matilda);
      }
    } catch (err) {
      console.error("❌ [Matilda] Error while initializing runtime:", err);
      createAgentRuntime(matilda);
    }
  })
  .catch((err) => {
    console.error("💥 [Matilda] Bootstrap failure:", err);
  });
