// <0001fafa> Phase 9.7c — Matilda Universal Import Fallback
import express from "express";
import path from "path";
import cors from "cors";
import * as matildaModule from "./agents/matilda/matilda.mjs"; // Import all possible exports

const app = express();
app.use(cors());
app.use(express.json());

// Serve static dashboard
const publicPath = path.join(process.cwd(), "public");
app.use(express.static(publicPath));

app.get("/", (_req, res) => {
  res.sendFile(path.join(publicPath, "dashboard.html"));
});

// 🧠 Smart Matilda handler resolution
app.post("/matilda", async (req, res) => {
  try {
    const { message } = req.body;
    const matilda =
      matildaModule.matilda?.handler ??
      matildaModule.matilda ??
      matildaModule.default?.handler ??
      matildaModule.default;

    if (!matilda) throw new Error("Matilda handler not found");
    const reply = await matilda(message);
    res.json({ reply });
  } catch (err) {
    console.error("❌ Matilda route error:", err);
    res.status(500).json({ error: "Matilda is unreachable" });
  }
});

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`🖥️  Dashboard + Matilda API running at http://localhost:${PORT}`);
});
