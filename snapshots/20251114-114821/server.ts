// <0001fb09> Phase 9.9j — Hot-Reloading Matilda Route (Chat vs Delegation)
import express from "express";
import path from "path";
import cors from "cors";
import { createRequire } from "module";

const require = createRequire(import.meta.url);
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

// 🔥 Always fresh import of Matilda
app.post("/matilda", async (req, res) => {
  try {
    delete require.cache[require.resolve("./agents/matilda/matilda.mjs")];
    const { matilda } = await import("./agents/matilda/matilda.mjs?" + Date.now());
    const reply = await matilda.handler(req.body.message);
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
