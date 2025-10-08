import express from "express";
import { ollamaPlan } from "../utils/ollamaPlan";
import { findClosestSkill } from "../../db/skills";
import { ensureSkill, runDynamicSkill } from "../../db/skillRegistry";

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const userMessage = req.body?.message;
    if (!userMessage) return res.json({ ok: false, reply: "No message provided." });

    console.log("<0001f9e1> Matilda received:", userMessage);

    // Step 1: Generate a code plan from Ollama
    const plan = await ollamaPlan(
      `Write a TypeScript async function implementing this task:\n"${userMessage}"\nReturn the function code only.`
    );

    // Step 2: Determine a simple skill name
    const skill = findClosestSkill(userMessage) || "generatedSkill";

    // Step 3: Create and run the skill
    const filePath = ensureSkill(skill, plan);
    const result = await runDynamicSkill(skill);

    return res.json({ ok: true, reply: result, skill, plan });
  } catch (err: any) {
    console.error("<0001f9e1> ❌ Matilda error:", err);
    return res.json({ ok: false, reply: "Error creating dynamic skill.", error: err.message });
  }
});

export default router;
