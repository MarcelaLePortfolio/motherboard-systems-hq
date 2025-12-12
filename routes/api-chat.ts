import express, { Request, Response } from "express";
import { runMatildaStub, MatildaChatResult } from "../matilda-chat-stub";

const router = express.Router();

/**

* POST /api/chat
*
* Matilda chat endpoint (stubbed pipeline).
* Accepts { message, agent } in the JSON body and returns a structured
* Matilda-style response using the runMatildaStub helper.
  */
  router.post("/api/chat", async (req: Request, res: Response) => {
  try {
  const { message, agent } = (req.body || {}) as {
  message?: string;
  agent?: string | null;
  };

  if (typeof message !== "string" || !message.trim()) {
  return res.status(400).json({
  ok: false,
  error: "Missing or invalid 'message' in request body.",
  });
  }

  const result: MatildaChatResult = await runMatildaStub({
  message,
  agent: agent ?? "matilda",
  });

  return res.json(result);
  } catch (err) {
  console.error("[/api/chat] Matilda stub pipeline error:", err);
  return res.status(500).json({
  ok: false,
  error: "Matilda pipeline stub encountered an unexpected error.",
  });
  }
  });

export default router;
