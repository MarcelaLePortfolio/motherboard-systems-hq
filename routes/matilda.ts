import express from "express";
import fs from "fs";
import path from "path";
import { sqlite } from "../db/client.ts";
import { ollamaChat } from "../scripts/utils/ollamaChat.ts";

export const router = express.Router();

/**
 * Utility: insert a task event
 */
function createTask(description: string, payload: any, agent = "Cade") {
  const stmt = sqlite.prepare(`
    INSERT INTO task_events (description, status, agent, type, payload)
    VALUES (?, 'pending', ?, 'delegation', ?)
  `);
  stmt.run(description, agent, JSON.stringify(payload));
}

router.post("/", async (req, res) => {
  const { message, delegate } = req.body;

  console.log("<0001fa9f> 📨 Matilda received:", { message, delegate });

  // Normalize text from dashboard button
  const input = delegate || message || "";

  // ---------------------------------------
  // 🔍 1. Delegation detection
  // ---------------------------------------
  const isDelegation =
    delegate ||
    input.startsWith("delegate:") ||
    input.startsWith("Delegate:") ||
    input.includes("🚀 Delegate");

  if (isDelegation) {
    console.log("<0001fb40> 🎯 Delegation detected");

    // Extract real instruction
    const cleanInstruction = input
      .replace("🚀 Delegate:", "")
      .replace("Delegate:", "")
      .replace("delegate:", "")
      .trim();

    // Create task event
    createTask("Delegated task", { instruction: cleanInstruction });

    console.log("<0001fb40> 📝 Delegation task created with payload:", cleanInstruction);

    return res.json({
      message:
        `🚀 Your task has been delegated! I've passed it along to Cade.\n\n` +
        `📄 Instruction: "${cleanInstruction}"\n` +
        `He’ll get right on it.`
    });
  }

  // ---------------------------------------
  // 🧠 2. Normal chat flow
  // ---------------------------------------
  try {
    const start = Date.now();
    const reply = await ollamaChat(input);
    const elapsed = ((Date.now() - start) / 1000).toFixed(2);

    console.log(`<0001fa9f> 🕒 Matilda total processing time: ${elapsed}s`);

    return res.json({ message: reply });

  } catch (err) {
    console.error("<0001fab5> ❌ Matilda chat error:", err);
    return res.status(500).json({ error: "Internal Matilda error" });
  }
});
