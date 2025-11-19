// <0001faee> Phase 9.2b — Reflection SSE Server Rebuild
import express from "express";
import cors from "cors";
import { sqlite } from "../../db/client";

const app = express();
app.use(cors());

app.get("/events/reflections", (req, res) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();

  res.write(`data: {"status":"connected"}\n\n`);

  const sendUpdate = () => {
    const rows = sqlite
      .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 10")
      .all();
    res.write(`data: ${JSON.stringify(rows)}\n\n`);
  };

  sendUpdate();
  const interval = setInterval(sendUpdate, 1000);
  req.on("close", () => clearInterval(interval));
});

app.listen(3101, () => {
  console.log("📡 Reflection SSE server running at http://localhost:3101/events/reflections");
});
