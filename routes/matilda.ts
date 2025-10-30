import express from "express";
import { ollamaChat } from "../scripts/utils/ollamaChat.ts";

export const router = express.Router();

router.post("/", async (req, res) => {
  const { message } = req.body;
  console.log("<0001fa9f> 📨 Matilda received message:", message);
  try {
    const start = Date.now();
    const reply = await ollamaChat(message);
    const elapsed = ((Date.now() - start) / 1000).toFixed(2);
    console.log(`<0001fa9f> 🕒 Matilda total processing time: ${elapsed}s`);
    return res.json({ reply });
  } catch (err) {
    console.error("<0001fab5> ❌ Matilda chat error:", err);
    return res.json({ reply: "🤖 (chat error)" });
  }
});
