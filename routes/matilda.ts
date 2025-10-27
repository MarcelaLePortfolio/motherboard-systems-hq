import { Router } from "express";
import { execSync } from "child_process";

const router = Router();

// Simple heartbeat
router.get("/ping", (_, res) => {
  res.json({ ok: true, msg: "Matilda online 💬" });
});

// Chat endpoint
router.post("/", async (req, res) => {
  const message = req.body?.message || "";
  console.log(`🧠 Matilda received: ${message}`);

  try {
    const response = execSync(
      `ollama run llama3 "You are Matilda, a sweet and witty AI assistant. Reply warmly to: ${message}"`,
      { encoding: "utf8" }
    );

    res.json({ message: response.trim() });
  } catch (err: any) {
    console.error("❌ Matilda Ollama error:", err.message);
    res.status(500).json({ error: "Matilda failed to respond" });
  }
});

export default router;
