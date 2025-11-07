import express from "express";
import { runSkill } from "../scripts/utils/runSkill";
import { ollamaPlan } from "../scripts/utils/ollamaPlan";

export const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const message = req.body.message?.toLowerCase() || "";
    const delegationTriggers = ["create", "read", "delete", "run", "execute", "write"];
    const shouldDelegate = delegationTriggers.some(t => message.includes(t));

    if (shouldDelegate) {
      const result = await runSkill("delegate");
      console.log(`🧠 Matilda delegated task: ${message}`);
      return res.json({ message: result });
    }

    const response = await ollamaPlan(message);
    console.log(`💬 Matilda responded: ${response}`);
    res.json({ message: response });
  } catch (err: any) {
    console.error("❌ Matilda error:", err);
    res.status(500).json({ message: "Matilda encountered an error." });
  }
});
