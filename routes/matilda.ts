import express from "express";
import { runSkill } from "../scripts/utils/runSkill.ts";

export const router = express.Router();

router.post("/", async (req, res) => {
  const message = req.body.message || "";
  console.log("<0001fab5> 🧠 Matilda received:", message);

  try {
    // 🧩 For now, assume all “create file” requests map to createFile skill
    if (message.toLowerCase().includes("create file")) {
      const payload = { filename: message.split(" ").pop() || "default.txt" };
      const result = await runSkill("createFile", payload);
      return res.json({ message: `✨ Delegation complete — ${result}` });
    }

    // Default fallback (chat response)
    return res.json({
      message: `Hello there! I'm Matilda — your friendly AI operator. How can I assist?`,
    });
  } catch (err: any) {
    console.error("❌ Matilda route error:", err);
    res.status(500).json({ error: err.message });
  }
});
