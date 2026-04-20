import express from "express";
import path from "path";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

import delegateRoutes from "./routes/api/delegate";
import tasksRoutes from "./routes/api/tasks";
import logsRoutes from "./routes/api/logs";
import systemHealthRoutes from "./routes/diagnostics/systemHealth";

const publicPath = path.join(process.cwd(), "public");
app.use(express.static(publicPath));
app.use(delegateRoutes);
app.use(tasksRoutes);
app.use(logsRoutes);
app.use("/diagnostics/systemHealth", systemHealthRoutes);

app.get("/", (_req, res) => {
  res.sendFile(path.join(publicPath, "dashboard.html"));
});

function buildMatildaReply(message: unknown): string {
  const text = typeof message === "string" ? message.trim() : "";

  if (!text) {
    return "Hi, I’m Matilda. I’m online in a local safe mode right now.";
  }

  const lower = text.toLowerCase();

  if (["hi", "hello", "hey"].includes(lower)) {
    return "Hi, I’m Matilda. I’m online and responding in local safe mode.";
  }

  if (lower.includes("status")) {
    return "I’m here in local safe mode. Full wiring pending.";
  }

  return `I received: "${text}". Local safe mode active.`;
}

app.post("/matilda", async (req, res) => {
  try {
    const reply = buildMatildaReply(req.body?.message);
    res.json({ reply });
  } catch (err) {
    res.status(500).json({ error: "Matilda is unreachable" });
  }
});

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
