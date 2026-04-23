import express, { Request, Response } from "express";

const router = express.Router();

type MatildaChatResult = {
  ok: true;
  agent: string;
  reply: string;
  source: "deterministic-local";
};

/**
 * Build a deterministic local Matilda reply without external stub dependency.
 * Keeps request/response shape stable for dashboard consumers.
 */
function buildDeterministicMatildaReply(
  message: string,
  agent: string
): MatildaChatResult {
  const text = message.trim();
  const normalizedAgent =
    (agent || "matilda").toString().trim() || "matilda";
  const lower = text.toLowerCase();

  if (!text) {
    return {
      ok: true,
      agent: normalizedAgent,
      reply: "Hi, I’m Matilda. I’m online and ready.",
      source: "deterministic-local",
    };
  }

  if (["hi", "hello", "hey"].includes(lower)) {
    return {
      ok: true,
      agent: normalizedAgent,
      reply: "Hi, I’m Matilda. I’m online and responding deterministically.",
      source: "deterministic-local",
    };
  }

  if (lower.includes("status")) {
    return {
      ok: true,
      agent: normalizedAgent,
      reply: "Matilda is online. Deterministic response mode is active.",
      source: "deterministic-local",
    };
  }

  return {
    ok: true,
    agent: normalizedAgent,
    reply: `I received your message: "${text}"`,
    source: "deterministic-local",
  };
}

/**
 * POST /api/chat
 *
 * Matilda chat endpoint (deterministic local pipeline).
 * Accepts { message, agent } in the JSON body and returns a structured
 * Matilda-style response using the local deterministic helper.
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

    const result: MatildaChatResult = buildDeterministicMatildaReply(
      message,
      agent ?? "matilda"
    );

    return res.json(result);
  } catch (err) {
    console.error("[/api/chat] Matilda deterministic pipeline error:", err);
    return res.status(500).json({
      ok: false,
      error: "Matilda deterministic pipeline encountered an unexpected error.",
    });
  }
});

export default router;
