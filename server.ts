import express from "express";
import bodyParser from "body-parser";
import { handleMatildaMessage } from "./scripts/agents/matilda-handler";
import { cadeCommandRouter } from "./scripts/agents/cade";

const app = express();
const PORT = process.env.PORT || 3001;

app.use(bodyParser.json());

// Health check
app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

// Matilda endpoint
app.post("/matilda", async (req, res) => {
  const { message } = req.body;
  console.log("📩 Hit /matilda route with body:", req.body);

  const result = await handleMatildaMessage("session1", message);

  // 🔗 If Matilda returns a Cade task, run it
  if (result.task) {
    console.log("🤝 Delegating to Cade:", result.task);
    try {
      const cadeResult = await cadeCommandRouter(result.task.command, result.task.payload);
      result.cadeResult = cadeResult;
    } catch (err: any) {
      console.error("❌ Cade delegation failed:", err);
      result.cadeResult = { status: "error", message: err?.message || String(err) };
    }
  }

  console.log("📤 Matilda replied:", result);
  res.json(result);
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Server listening on http://localhost:${PORT}`);
  console.log("Mounted: GET /health, POST /matilda, static /public");
});
