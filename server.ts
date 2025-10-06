import express from "express";
import bodyParser from "body-parser";

import { cadeCommandRouter } from "./scripts/agents/cade";
import { cadeCommandRouter as cadeDynamic } from "./scripts/agents/cade_dynamic";

const app = express();
const PORT = process.env.PORT || 3001;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));


// Health check
app.get("/health", (_, res) => res.json({ status: "ok" }));

// Main Cade route
app.post("/matilda", async (req, res) => {
  try {
    const { command, payload } = req.body;
    console.log("⚡ Delegating to Cade:", command);
    const result = await cadeCommandRouter(command, payload);
    res.json(result);
  } catch (err) {
    console.error("❌ /matilda failed:", err);
    res.status(500).json({ error: err.message || String(err) });
  }
});

// Dynamic Cade route
app.post("/matilda-dynamic", async (req, res) => {
  try {
    const { command, payload } = req.body;
    console.log("⚡ Delegating to CadeDynamic:", command);
    const result = await cadeDynamic(command, payload);
    res.json(result);
  } catch (err) {
    console.error("❌ /matilda-dynamic failed:", err);
    res.status(500).json({ error: err.message || String(err) });
  }
});

app.listen(PORT, () => {
  console.log(`✅ Server listening on http://localhost:${PORT}`);
  console.log("Mounted: GET /health, POST /matilda, POST /matilda-dynamic, /status, /tasks, /logs, /dashboard");
});
