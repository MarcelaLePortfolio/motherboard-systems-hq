import { fileURLToPath } from 'url';
import { dirname } from 'path';
import express from 'express';
import bodyParser from 'body-parser';
import nodeFetch from 'node-fetch';
import { exec } from 'child_process';
import fs from 'fs';
import path from 'path';

// --- ES Module Fixes ---
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
// --- End Fixes ---

// Define dummy status map (assuming this was defined earlier in your script)
const statusMap = {
  Matilda: { status: "offline", lastCheck: Date.now() },
  Cade: { status: "offline", lastCheck: Date.now() },
  Effie: { status: "offline", lastCheck: Date.now() },
};

const app = express();
app.use(bodyParser.json());

// STATIC FILE SERVING FIX
app.use(express.static(path.join(__dirname, 'public'))); 

// --- 1️⃣ Reflections Stream Endpoint ---
app.get("/reflections-stream", (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.write('data: Connected to Reflections Stream\n\n');
  
  // Placeholder for stream logic
});

// --- 2️⃣ Chat Endpoint ---
app.post("/api/chat", async (req, res) => {
  const { message: userMessage } = req.body;
  try {
    const reply = "(response placeholder)"; // Simplified response
    const logFile = 'chat.log';

    // The fs module is safe to use as synchronous file append
    fs.appendFileSync(
      logFile,
      JSON.stringify({
        timestamp: Math.floor(Date.now() / 1000),
        agent: "matilda",
        event: `chat: ${userMessage} -> ${reply}`
      }) + "\n"
    );

    res.json({ reply });
  } catch (err) {
    console.error("❌ Error in /api/chat:", err);
    res.status(500).json({ reply: "(error)" });
  }
});

// --- 3️⃣ Agent Status Endpoint ---
app.get("/api/agent-status", (req, res) => {
  exec("pm2 jlist", (err, stdout) => {
    if (err) return res.json(statusMap);

    try {
      const list = JSON.parse(stdout);
      const map = { ...statusMap };
      list.forEach(proc => {
        const name = proc.name.toLowerCase();
        const online = proc.pm2_env.status === "online";
        if (name.includes("matilda")) map.Matilda.status = online ? "online" : "offline";
        if (name.includes("cade")) map.Cade.status = online ? "online" : "offline";
        if (name.includes("effie")) map.Effie.status = online ? "online" : "offline";
      });
      res.json(map);
    } catch (err) {
      console.error("❌ Error in /api/agent-status:", err);
      res.json(statusMap);
    }
  });
});

// --- 4️⃣ Start Server ---
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`✅ Dashboard live on port ${PORT}`));
