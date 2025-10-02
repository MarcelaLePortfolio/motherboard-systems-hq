import express from "express";
import * as matildaModule from "./scripts/agents/matilda-handler";
import { dashboardRoutes } from "./scripts/routes/dashboard";
import path from "path";

const { matildaHandler } = matildaModule;

const app = express();
app.use(express.json());

// ✅ Serve static frontend files from top-level public/
app.use(express.static(path.join(process.cwd(), "public")));

app.get("/health", (_req, res) => res.json({ status: "ok" }));
app.post("/matilda", async (req, res) => {
  const { command, payload, actor } = req.body;
  const result = await matildaHandler(command, payload, actor);
  res.json(result);
});

// ✅ Mount backend dashboard API routes
app.use("/", dashboardRoutes);

// ✅ Shortcut: /dashboard → dashboard.html
app.get("/dashboard", (_req, res) => {
  res.sendFile(path.join(process.cwd(), "public", "dashboard.html"));
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`✅ Server listening on http://localhost:${PORT}`);
  console.log("Mounted: GET /health, POST /matilda, /status, /tasks, /logs, /dashboard");
});
