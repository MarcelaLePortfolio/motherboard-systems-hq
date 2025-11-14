import express from "express";
import { submitTask } from "../_local/agent-runtime/submit-task";

const router = express.Router();

router.post("/tasks/delegate", async (req, res) => {
  const { prompt } = req.body;
  if (!prompt) return res.status(400).json({ success: false, error: "Prompt required" });

  try {
    const taskId = await submitTask("matilda", { prompt });
    res.json({ success: true, taskId });
  } catch (err) {
    console.error("Delegation failed:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

export default router;
