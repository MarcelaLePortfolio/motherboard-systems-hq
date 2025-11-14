import express from "express";
import { sqlite } from "../db/client.ts";
import { ollamaChat } from "../scripts/utils/ollamaChat.ts";

export const router = express.Router();
router.use(express.json());

/**
 * Insert a task event
 */
function createTask(description: string, payload: any, agent = "Cade") {
  const stmt = sqlite.prepare(`
    INSERT INTO task_events (description, status, agent, type, payload)
    VALUES (?, 'pending', ?, 'delegation', ?)
  `);
  stmt.run(description, agent, JSON.stringify(payload));
}

router.post("/", async (req, res) => {
  console.log("🔥 RAW BODY:", req.body);

  const { message, delegate } = req.body;
  const input = delegate || message || "";

  console.log("<0001fa9f> 📨 Matilda received:", { message, delegate });

  // ---------------------------------------
  // ---------------------------------------
    // ---------------------------------------

    // Delegation detection (normalized & robust)

    // ---------------------------------------

  

    const normalized = input.trim().toLowerCase();

  

    if (normalized.startsWith("delegate:")) {

      console.log("<0001fb40> Delegation detected");

  

      const cleanInstruction = input.replace(/delegate\s*:/i, "").trim();

  

      createTask("Delegated task", { instruction: cleanInstruction });

      console.log("<0001fb40> Delegated task created:", cleanInstruction);

  

      return res.json({ message: `Task delegated to Cade. Instruction: "${cleanInstruction}"` });

    }


  try {
    const reply = await ollamaChat(input);
    return res.json({ message: reply });
  } catch (err) {
    console.error("<0001fab5> ❌ Matilda chat error:", err);
    return res.status(500).json({ error: "Internal Matilda error" });
  }
});
