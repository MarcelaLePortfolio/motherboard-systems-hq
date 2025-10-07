// <0001fbDA> matilda-router – hybrid chat + skill with auto fallback
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
    console.log("<0001fbDA> 🧭 Matilda plan:", plan);

    // ✅ Known skill list
    const knownSkills = ["file.create", "file.write", "write to file", "create file"];

    // 🧠 If plan action not recognized, switch to neutral chat mode
    if (!knownSkills.includes(plan.action)) {
      const chatReply = await ollamaChat(userMessage);
      return res.json({ ok: true, reply: chatReply, mode: "chat" });
    }

    // ⚙️ Otherwise execute with Cade
    const result = await runSkill(plan.action, plan.params);
    console.log("<0001fbDA> ⚙️ Cade result:", result);

    res.json({
      ok: true,
      reply: result.result || "Task completed!",
      plan,
      raw: result,
      mode: "skill",
    });
  } catch (err: any) {
    console.error("<0001fbDA> ❌ Matilda error:", err);
    res.status(500).json({
      ok: false,
      reply: "I'm sorry, something went wrong.",
      error: err.message || String(err),
    });
  }
});

export default router;
