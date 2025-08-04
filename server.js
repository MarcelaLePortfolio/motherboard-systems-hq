import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { exec } from "child_process";
import fs from "fs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, "ui/dashboard")));
app.use(express.static(path.join(__dirname, "public")));

// --- 1️⃣ Agent Status via PM2 ---
app.get("/api/agent-status", (req, res) => {
  exec("pm2 jlist", (err, stdout) => {
    if (err) return res.json({
      Matilda: { status: "offline", icon: "🔴" },
      Cade: { status: "offline", icon: "🔴" },
      Effie: { status: "offline", icon: "🔴" }
    });

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
        if (name.includes("matilda")) statusMap.Matilda = { status: online ? "online" : "offline", icon: online ? "��" : "🔴" };
        if (name.includes("cade")) statusMap.Cade = { status: online ? "online" : "offline", icon: online ? "🟢" : "🔴" };
        if (name.includes("effie")) statusMap.Effie = { status: online ? "online" : "offline", icon: online ? "🟢" : "🔴" };
      });
      res.json(statusMap);
    } catch {
      res.json({
        Matilda: { status: "offline", icon: "🔴" },
        Cade: { status: "offline", icon: "🔴" },
        Effie: { status: "offline", icon: "🔴" }
      });
    }
  });
});

// --- 2️⃣ Ops Stream from Log File ---
const LOG_FILE = path.join(__dirname, "ui/dashboard/ticker-events.log");
if (!fs.existsSync(LOG_FILE)) fs.writeFileSync(LOG_FILE, "");

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
  } catch {
    res.json([]);
  }
});

// --- 3️⃣ Project Tracker with Start Time ---
app.get("/api/project-tracker", (req, res) => {
  try {
    const logs = fs.readFileSync(LOG_FILE, "utf-8").trim().split("\n").filter(Boolean);
    const tasks = {};
    logs.forEach(line => {
      let entry;
      try { entry = JSON.parse(line); }
      catch { 
        const parts = line.split(" | ");
        entry = { event: parts[1] || line, agent: parts[0] || "unknown", timestamp: Date.now()/1000 }; 
      }

      if (!entry.event) return;

      // Convert epoch timestamp to local time
      const readableTime = entry.timestamp 
        ? new Date(parseInt(entry.timestamp) * 1000).toLocaleTimeString() 
        : new Date().toLocaleTimeString();

      // Detect task creation and completion
      if (entry.event.startsWith("processing-task:")) {
        const task = entry.event.split(":")[1];
        tasks[task] = { task, status: "in-progress", agent: entry.agent, startTime: readableTime };
      }
      if (entry.event.startsWith("completed-task:")) {
        const task = entry.event.split(":")[1];
        // Preserve the original start time if exists
        tasks[task] = { task, status: "complete", agent: entry.agent, startTime: tasks[task]?.startTime || readableTime };
      }
    });

    res.json(Object.values(tasks));
  } catch {
    res.json([]);
  }
});

// --- 4️⃣ Serve Dashboard ---
app.listen(PORT, () => {
  console.log(`✅ Dashboard live on port ${PORT}`);
  console.log(`Endpoints: /api/agent-status /api/ops-stream /api/project-tracker`);
});
