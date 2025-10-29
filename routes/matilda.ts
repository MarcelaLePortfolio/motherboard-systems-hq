import express from "express";
import { matilda } from "../scripts/agents_full/matilda.ts";

export const router = express.Router();

router.post("/", async (req, res) => {
  const message = req.body?.message?.trim();
  if (!message) return res.json({ message: "⚠️ Empty message received." });

  try {
    const reply = await matilda.handler(message);
    res.json({ message: reply });
  } catch (err) {
    console.error("<0001fab5> ❌ Matilda route error:", err);
    res.status(500).json({ message: "Matilda encountered an error." });
  }
});

export default router;
