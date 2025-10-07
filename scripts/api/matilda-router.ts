// <0001f9e1> Matilda router – now consults ontology before delegation
import express from "express";
import { ollamaPlan } from "../utils/ollamaPlan";
import { ollamaChat } from "../utils/ollamaChat";
import { runSkill } from "../utils/runSkill";
import { findClosestSkill } from "../../db/skills";

const router = express.Router();

router.post("/", express.json(), async (req, res) => {
  const userMessage = req.body?.message || "";
  if (!userMessage) {
    return res.status(400).json({ ok: false, error: "Missing 'message' field" });
  }

  try {
    const plan = await ollamaPlan(userMessage);
    console.log("<0001f9e1> 🧭 Matilda plan:", plan);

    let action = plan.action;
    const inferred = findClosestSkill(action);
    if (inferred && inferred !== action) {
      console.log(`<0001f9e1> Ontology inference → ${action} → ${inferred}`);
      action = inferred;
    }

    // Decide mode
    const isPrefixed = /^(file|dashboard|tasks|logs|status)\./.test(action);

    if (isPrefixed) {
      const result = await runSkill(action, plan.params);
      console.log("<0001f9e1> ⚙️ Cade result:", result);
      return res.json({
        ok: true,
        reply: result.result || "✅ Task completed!",
        plan: { ...plan, action },
        raw: result,
        mode: "skill",
      });
    }

    // Otherwise chat naturally
    const chatReply = await ollamaChat(userMessage);
    return res.json({ ok: true, reply: chatReply, mode: "chat" });
  } catch (err: any) {
    console.error("<0001f9e1> ❌ Matilda error:", err);
    res.status(500).json({
      ok: false,
      reply: "I'm sorry, something went wrong.",
      error: err.message || String(err),
    });
  }
});

export default router;
