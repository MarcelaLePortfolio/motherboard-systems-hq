import express from "express";
<<<<<<< HEAD
import { runSkill } from "../scripts/utils/runSkill";
import { broadcast } from "../server";
=======
import { runSkill } from "../scripts/utils/runSkill.ts";
import { ollamaPlan } from "../scripts/utils/ollamaPlan.ts";
>>>>>>> 084506c4 (<0001f9fa> v0.3.36 — Matilda Conversational Mode Restored)

export const router = express.Router();

router.post("/", async (req, res) => {
  try {
<<<<<<< HEAD
    const { message } = req.body;
    console.log("💬 Matilda received:", message);

    if (message.includes("create file")) {
      const filename = message.replace("create file", "").trim() || "newfile";
      const result = await runSkill("createFile", { filename });
      broadcast(`Matilda→Cade delegation success: ${result}`);
      return res.json({ message: result });
    }

    const response = "🤖 Matilda: no matching skill detected.";
    broadcast(response);
    return res.json({ message: response });
  } catch (err) {
    const errorMsg = `❌ Matilda encountered an error: ${err.message}`;
    console.error(errorMsg);
    broadcast(errorMsg);
    return res.json({ message: errorMsg });
=======
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
>>>>>>> 084506c4 (<0001f9fa> v0.3.36 — Matilda Conversational Mode Restored)
  }
});
