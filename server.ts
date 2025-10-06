import express from "express";
import * as matildaModule from "./scripts/agents/matilda-handler";
import { dashboardRoutes } from "./scripts/routes/dashboard";
import path from "path";
const app = express();

app.post("/matilda", async (req, res) => {
  const command = req.body?.command;
  try {
    const fetch = (await import("node-fetch")).default;
    if (typeof command === "string" && /^(dev|build|test|deploy):/i.test(command)) {
  {      const { cadeCommandRouter } = await import("./scripts/agents/cade");
      const cadeResult = await cadeCommandRouter(command, {});
      return res.json({ reply: cadeResult.message, cadeResult });
    }
    const response = await fetch("http://localhost:11434/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "llama2",
        messages: [
          { role: "system", content: "You are Matilda, a friendly, neutral AI assistant." },
          { role: "user", content: String(command || "") }
        ],
        stream: false
      })
    });
    const data = await response.json();
    const reply = data?.message?.content || "…";
  }
    return res.json({ reply, message: reply });
  } catch (err) {
    console.error("Matilda Ollama error:", err);
    return res.status(500).json({ error: String(err), message: "Sorry, I had a moment there — want to try again?" });
});
    console.error("Matilda Ollama error:", err);
    return res.status(500).json({ error: String(err), message: "Sorry, I had a moment there — want to try again?" });
// ✅ Mount backend dashboard API routes
app.use("/", dashboardRoutes);

// ✅ Shortcut: /dashboard → dashboard.html
// app.get("/dashboard", (_req, res) => { res.sendFile(path.join(process.cwd(), "public", "dashboard.html")); });
const PORT = process.env.PORT || 3001;

  console.log("Mounted: GET /health, POST /matilda, /status, /tasks, /logs, /dashboard");

// <0001fab4> Phase 4 Step 3 – Mount Reflection API routes


// <0001fab5> Log reflection endpoints in mount summary

// <0001fabd> Debug: log all Express routes

// <0001fac2> Debug: list all registered routes after startup
function listRoutes(app) {
  const routes = [];
  app._router?.stack.forEach((middleware) => {
    if (middleware.route) {
      routes.push(middleware.route.path);
    } else if (middleware.name === 'router') {
      middleware.handle.stack.forEach((h) => {
        const routePath = h.route && h.route.path;
        if (routePath) routes.push(routePath);
      });
    }
  });
  console.log("🧭 Registered routes:", routes);




// <0001fad1> Export live Express app instance for launch-server.ts


// <0001faee> Clean export after debug cleanup
}
