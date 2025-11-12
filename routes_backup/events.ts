import express, { Request, Response } from "express";
const router = express.Router();






import { getAllAgentsStatus } from "../scripts/utils/agentStatus.js";


// 🧠 Basic Server-Sent Events stream for live agent updates
  res.set({
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  res.flushHeaders();
  res.write(`event: ping\ndata: {}\n\n`);

  const sendStatus = async () => {
    try {
      const agents = await getAllAgentsStatus();
      res.write(`event: agent\ndata: ${JSON.stringify({ agents })}\n\n`);
    } catch (err) {
      console.error("❌ SSE broadcast failed:", err);
    }
  };

  // Initial snapshot
  await sendStatus();

  // Heartbeat + refresh every 5 s
  const interval = setInterval(sendStatus, 5000);

  req.on("close", () => {
    clearInterval(interval);
    console.log("❌ SSE client disconnected");
  });
});

