import express from "express";
import { ollamaChat } from "../scripts/utils/ollamaChat.ts";

export const router = express.Router();

// 🔧 TEMP STUB — this will be replaced with real Cade pipeline next
async function delegateTaskToCade(description: string) {
  console.log("<0001fb30> 🚀 Delegation request received:", description);

  // Simulated Cade acceptance
  await new Promise((r) => setTimeout(r, 500));
  console.log("<0001fb30> 🤖 Cade accepted task");

  // Simulated Effie execution
  await new Promise((r) => setTimeout(r, 800));
  console.log("<0001fb30> 🧰 Effie executed delegated task");

  return "Delegation completed (stub)";
}

router.post("/", async (req, res) => {
  const { message, delegate } = req.body;

  console.log("<0001fa9f> 📨 Matilda received:", { message, delegate });

  try {
    // =======================================
    // 🚀 Delegation Mode
    // =======================================
    if (delegate) {
      const result = await delegateTaskToCade(message);
      return res.json({
        message: `🚀 Delegation started:\n${message}\n\n${result}`
      });
    }

    // =======================================
    // 💬 Normal Chat Mode
    // =======================================
    const start = Date.now();
    const reply = await ollamaChat(message);
    const elapsed = ((Date.now() - start) / 1000).toFixed(2);

    console.log(`<0001fa9f> 🕒 Matilda chat time: ${elapsed}s`);
    return res.json({ message: reply });

  } catch (err) {
    console.error("<0001fab5> ❌ Matilda error:", err);
    return res.status(500).json({ error: "Internal Matilda error" });
  }
});
