import express from "express";
import { matilda } from "../scripts/agents_full/matilda.ts";

export const router = express.Router();

router.post("/", async (req, res) => {
  const message = req.body?.message?.trim();
  if (!message) return res.json({ message: "⚠️ Empty message received." });

  try {
    // Begin Matilda's thinking process
    const replyPromise = matilda.handler(message);

    // Respond immediately if she takes too long
    const reply = await Promise.race([
      replyPromise,
      new Promise(resolve =>
        setTimeout(() => resolve("💭 Thinking... please wait a moment."), 500)
      ),
    ]);

    // Send the initial or full reply instantly
    res.json({ message: reply });

    // Allow post-processing (logging/reflection) to continue in background
    replyPromise.catch(err =>
      console.error("<0001fab5> ❌ Matilda background error:", err)
    );
  } catch (err) {
    console.error("<0001fab5> ❌ Matilda route error:", err);
    res.status(500).json({ message: "Matilda encountered an error." });
  }
});
