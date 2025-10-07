// <0001fbD1> matilda-router – connected to Cade dynamic skills
import express from "express";
import { ollamaPlan } from "../utils/ollamaPlan";
import { runSkill } from "../utils/runSkill";

const router = express.Router();

// POST /matilda
router.post("/", express.json(), async (req, res) => {
  const userMessage = req.body?.message || "";
  if (!userMessage) {
    return res.status(400).json({ ok: false, error: "Missing 'message' field" });
  }

  try {
    // 🧠 1. Matilda asks Ollama for a plan
    const plan = await ollamaPlan(userMessage);
    console.log("<0001fbD1> 🧭 Matilda plan:", plan);

    // ⚙️ 2. Cade executes that plan
    const result = await runSkill(plan.action, plan.params);
    console.log("<0001fbD1> ⚙️ Cade result:", result);

    // 💬 3. Matilda replies to the dashboard
    res.json({
      ok: true,
      reply: `✅ ${result?.result || "Task completed!"}`,
      plan,
    });
  } catch (err: any) {
    console.error("<0001fbD1> ❌ Matilda error:", err);
    res.status(500).json({
      ok: false,
      error: err.message || String(err),
    });
  }
});

export default router;
