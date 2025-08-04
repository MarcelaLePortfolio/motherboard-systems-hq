import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { exec } from "child_process";
import fs from "fs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files
app.use(express.static(path.join(__dirname, "ui/dashboard")));
app.use(express.static(path.join(__dirname, "public")));

// --- 1️⃣ Real Agent Status via PM2 ---
app.get("/api/agent-status", (req, res) => {
  exec("pm2 jlist", (err, stdout) => {
    if (err) {
      console.error("❌ PM2 error:", err);
      return res.json({
        Matilda: { status: "offline", icon: "🔴" },
        Cade: { status: "offline", icon: "🔴" },
        Effie: { status: "offline", icon: "🔴" }
      });
    }

    try {
      const list = JSON.parse(stdout);
      const statusMap = {
        Matilda: { status: "offline", icon: "🔴" },
        Cade: { status: "offline", icon: "🔴" },
        Effie: { status: "offline", icon: "🔴" }
      };

      list.forEach(proc => {
        const name = proc.name.toLowerCase();
        const online = proc.pm2_env.status === "online";
        if (name.includes("matilda")) statusMap.Matilda = { status: online ? "online" : "offline", icon: online ? "🟢" : "🔴" };
        if (name.includes("cade")) statusMap.Cade = { status: online ? "online" : "offline", icon: online ? "🟢" : "🔴" };
        if (name.includes("effie")) statusMap.Effie = { status: online ? "online" : "offline", icon: online ? "🟢" : "🔴" };
      });

      res.json(statusMap);
    } catch (e) {
      console.error("❌ Failed to parse PM2 list:", e);
      res.json({
        Matilda: { status: "offline", icon: "🔴" },
        Cade: { status: "offline", icon: "🔴" },
        Effie: { status: "offline", icon: "🔴" }
      });
    }
  });
});

// --- 2️⃣ Ops Stream from Real Log File ---
const LOG_FILE = path.join(__dirname, "ui/dashboard/ticker-events.log");

// Ensure log file exists
if (!fs.existsSync(LOG_FILE)) fs.writeFileSync(LOG_FILE, "");

// Endpoint: Return last 20 lines (supports JSON logs)
app.get("/api/ops-stream", (req, res) => {
  try {
    const logs = fs.readFileSync(LOG_FILE, "utf-8").trim().split("\n").filter(Boolean);
    const events = logs.slice(-20).map(line => {
      try {
        const obj = JSON.parse(line);
        return {
          time: new Date(parseInt(obj.timestamp) * 1000).toLocaleTimeString(),
          message: `${obj.agent} | ${obj.event}`
        };
      } catch {
        const [time, message] = line.split(" | ");
        return { time: time || new Date().toLocaleTimeString(), message: message || line };
      }
    });
    res.json(events);
  } catch (err) {
    console.error("❌ Failed to read log file:", err);
    res.json([]);
  }
});

// --- 3️⃣ Serve Dashboard ---
app.listen(PORT, () => {
  console.log(`✅ Dashboard live on port ${PORT}`);
  console.log(`Endpoints: /api/agent-status /api/ops-stream`);
});
