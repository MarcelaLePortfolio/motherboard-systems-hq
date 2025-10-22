import { Router, Request, Response } from "express";
import { getCadeStatus } from "../scripts/agents/cade";

const router = Router();
let clients: Response[] = [];

router.get("/", (req: Request, res: Response) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();

  clients.push(res);
  console.log(`🔌 SSE client connected (${clients.length} total)`);

  req.on("close", () => {
    clients = clients.filter(c => c !== res);
    console.log(`❌ SSE client disconnected (${clients.length} remaining)`);
  });
});

export function broadcastAgentUpdate(update: any) {
  console.log("📡 broadcastAgentUpdate:", update);
  clients.forEach(c => c.write(`event: agent\ndata: ${JSON.stringify(update)}\n\n`));
  c.flush && c.flush();
}

export function broadcastLogUpdate(update: any) {
  console.log("📡 broadcastLogUpdate:", update);
  clients.forEach(c => c.write(`event: log\ndata: ${JSON.stringify(update)}\n\n`));
  c.flush && c.flush();
}

export default router;
