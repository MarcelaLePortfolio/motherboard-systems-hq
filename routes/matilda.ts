import { Router } from "express";
import { execSync } from "child_process";
import { runSkill } from "../scripts/utils/runSkill.ts";
import { ollamaPlan } from "../scripts/utils/ollamaPlan.ts";

const router = Router();

/**
 * <0001faa4> Matilda Conversational + Delegational
 * Decides whether to respond conversationally or route a task to Cade.
 */
router.post("/", async (req, res) => {
  const message = req.body?.message?.trim();
  if (!message) return res.json({ message: "⚠️ Empty message received." });

  try {
    // 🧭 Step 1 — Detect potential delegation
    const lower = message.toLowerCase();
    const delegationTriggers = ["create", "read", "delete", "run", "execute", "write"];
    const shouldDelegate = delegationTriggers.some(t => lower.includes(t));

    // 🧩 Step 2 — If delegation, route to Cade via runSkill
    if (shouldDelegate) {
      const inferredType = lower.includes("delete")
        ? "deleteFile"
        : lower.includes("read")
        ? "readFile"
        : "createFile";

      const result = await runSkill({
        type: inferredType,
        params: { path: "memory/delegated.txt", content: `Task by Matilda: ${message}` }
      });

      return res.json({
        message: `✨ Delegation complete — ${result.message}`
      });
    }

    // 💬 Step 3 — Otherwise, respond conversationally via Ollama
    const response = execSync(`ollama run llama3 "You are Matilda, a sweet, witty AI companion. Reply naturally to: ${message}"`, { encoding: "utf8" });
    res.json({ message: response.trim() });

  } catch (err: any) {
    res.json({ message: `❌ Matilda encountered an error: ${err.message}` });
  }
});

export default router;
