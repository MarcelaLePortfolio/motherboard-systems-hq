import express from "express";
import { runSkill } from "../scripts/utils/runSkill.ts";
import { ollamaPlan } from "../scripts/utils/ollamaPlan.ts";

export const router = express.Router();

router.post("/", async (req, res) => {
  const message = req.body?.message?.trim();
  if (!message) return res.json({ message: "⚠️ Empty message received." });

  try {
    const lower = message.toLowerCase();
    const delegationTriggers = ["create", "read", "delete", "run", "execute", "write"];
    const shouldDelegate = delegationTriggers.some(t => lower.includes(t));

    if (shouldDelegate) {
      const result = await runSkill("delegate", { message });
      return res.json({ message: result });
    }

    const response = await ollamaPlan(message);
    res.json({ message: response });
  } catch (err: any) {
    console.error("<0001fab5> ❌ Matilda route error:", err);
    res.status(500).json({ message: "Matilda encountered an error." });
  }
});
