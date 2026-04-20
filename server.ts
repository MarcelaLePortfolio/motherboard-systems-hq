import express from "express";
import path from "path";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

import delegateRoutes from "./routes/api/delegate";
import tasksRoutes from "./routes/api/tasks";
import logsRoutes from "./routes/api/logs";

const publicPath = path.join(process.cwd(), "public");
app.use(express.static(publicPath));
app.use(delegateRoutes);
app.use(tasksRoutes);
app.use(logsRoutes);

app.get("/", (_req, res) => {
  res.sendFile(path.join(publicPath, "dashboard.html"));
});

function buildMatildaReply(message: unknown): string {
  const text = typeof message === "string" ? message.trim() : "";

  if (!text) {
    return "Hi, I’m Matilda. I’m online in a local safe mode right now. Give me a short request and I’ll acknowledge it.";
  }

  const lower = text.toLowerCase();

  if (["hi", "hello", "hey", "yo", "sup"].includes(lower)) {
    return "Hi, I’m Matilda. I’m online and responding in local safe mode.";
  }

  if (lower.includes("status") || lower.includes("are you there")) {
    return "I’m here and responding in local safe mode. Full Matilda wiring is still pending.";
  }

  return `I received your message: "${text}". I’m running in local safe mode, so deeper Matilda reasoning is not wired yet.`;
}

// Phase 487 — deterministic local Matilda route
app.post("/matilda", async (req, res) => {
  try {
    const reply = buildMatildaReply(req.body?.message);
    res.json({ reply });
  } catch (err) {
    console.error("❌ Matilda route error:", err);
    res.status(500).json({ error: "Matilda is unreachable" });
  }
});

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`🖥️ Dashboard + Matilda API (Hot Reload) running at http://localhost:${PORT}`);
});
