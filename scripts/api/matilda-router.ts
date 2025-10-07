// <0001fbE3> matilda-router – route all prefixed actions to Cade
import express from "express";
import { ollamaPlan } from "../utils/ollamaPlan";
import { ollamaChat } from "../utils/ollamaChat";
import { runSkill } from "../utils/runSkill";

const router = express.Router();

router.post("/", express.json(), async (req, res) => {
  const userMessage = req.body?.message || "";
  if (!userMessage) {
    return res.status(400).json({ ok: false, error: "Missing 'message' field" });
  }

  try {
    const plan = await ollamaPlan(userMessage);
    console.log("<0001fbE3> 🧭 Matilda plan:", plan);

    // If the action starts with an approved prefix, hand off to Cade
    const isPrefixed = /^(file|dashboard|tasks|logs|status)\./.test(plan.action);

    if (isPrefixed) {
      const result = await runSkill(plan.action, plan.params);
      console.log("<0001fbE3> ⚙️ Cade result:", result);
      return res.json({
        ok: true,
        reply: result.result || "✅ Task completed!",
        plan,
        raw: result,
        mode: "skill",
      });
    }

    // Otherwise, chat naturally
    const chatReply = await ollamaChat(userMessage);
    return res.json({ ok: true, reply: chatReply, mode: "chat" });
  } catch (err: any) {
    console.error("<0001fbE3> ❌ Matilda error:", err);
    res.status(500).json({
      ok: false,
      reply: "I'm sorry, something went wrong.",
      error: err.message || String(err),
    });
  }
});

export default router;
