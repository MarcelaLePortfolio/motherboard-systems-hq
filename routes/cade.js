import express from "express";
import { ollamaPlan } from "../scripts/utils/ollamaPlan.js";
import { runSkill } from "../scripts/utils/runSkill.js";
import { pushLog } from "../scripts/utils/pushLog.js";
import { pushTask } from "../scripts/utils/pushTask.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const { message } = req.body || {};
  console.log("🤖 Cade received:", message);

  try {
    // Step 1: Let Ollama interpret the task
    const plan = await ollamaPlan(message);
    console.log("🧩 Ollama Plan:", plan);

    // Step 2: Execute via Cade’s skill runtime
    const result = await runSkill(plan, { actor: "cade" });
    console.log("⚙️ Execution Result:", result);

    await pushTask({ task: plan?.action || "unknown", status: "Complete" });
    res.json({
      status: "success",
      received: message,
      plan,
      result,
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    console.error("❌ Cade error:", err);
    await pushLog({ level: "error", message: `Cade error: ${err.message}` });
    res.status(500).json({ status: "error", message: err.message });
  }
});

export default router;
