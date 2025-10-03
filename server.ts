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
  const { command } = req.body;

  if (typeof command === "string" && /^(dev|build|test|deploy):/i.test(command)) {
    return res.status(299).json({ passthrough: true });
  }

  try {
    const fetch = (await import("node-fetch")).default;
    const response = await fetch("http://localhost:11434/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "llama2",
        messages: [
          { role: "system", content: "You are Matilda, a friendly, neutral AI assistant. Be conversational, casual, and helpful." },
          { role: "user", content: String(command || "") }
        ],
        stream: false
      })
    });

    const data: any = await response.json();
    const reply: string = data?.message?.content || (Array.isArray(data?.messages) ? data.messages.map((m: any) => m.content).join(" ") : "…");

    return res.json({ reply, message: reply });
  } catch (err) {
    console.error("Matilda Ollama error:", err);
    return res.status(500).json({ error: String(err), message: "Sorry, I had a moment there — want to try again?" });
  }
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
