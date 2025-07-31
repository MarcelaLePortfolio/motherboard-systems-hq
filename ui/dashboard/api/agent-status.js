import express from "express";
import fs from "fs";

const app = express();
const PORT = 3081;

// Existing status endpoint
app.get("/", (req, res) => {
  const now = Math.floor(Date.now() / 1000);

  // Basic logic: consider agent online if last heartbeat < 70s
  let status = { cade: "offline", effie: "offline", matilda: "offline" };

  try {
    const lines = fs.readFileSync("ui/dashboard/ticker-events.log", "utf-8")
      .trim().split("\n")
      .slice(-200)
      .map(line => JSON.parse(line));

    const lastSeen = { cade: 0, effie: 0, matilda: 0 };
    lines.forEach(ev => {
      if (ev.agent in lastSeen && ev.event === "agent-online") {
        lastSeen[ev.agent] = Math.max(lastSeen[ev.agent], parseInt(ev.timestamp));
      }
    });

    Object.keys(lastSeen).forEach(agent => {
      if (now - lastSeen[agent] <= 70) status[agent] = "online";
    });
  } catch (err) {
    console.error("⚠️ Status read error:", err.message);
  }

  status.timestamp = now;
  res.json(status);
});

// ✅ New ticker endpoint
app.get("/ticker", (req, res) => {
  try {
    const lines = fs.readFileSync("ui/dashboard/ticker-events.log", "utf-8")
      .trim()
      .split("\n")
      .slice(-50)
      .map(JSON.parse);
    res.json(lines);
  } catch {
    res.json([]);
  }
});

app.listen(PORT, () => {
  console.log(`✅ Status & Ticker API running at http://localhost:${PORT}`);
});
