import { Router, Request, Response } from "express";

const router = Router();
let clients: Response[] = [];

router.get("/", (req: Request, res: Response) => {
  res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("X-Accel-Buffering", "no"); // disable proxy buffering
  res.flushHeaders();

  clients.push(res);
  console.log(`🔌 SSE client connected (${clients.length} total)`);

  // periodic keep-alive ping
  const ping = setInterval(() => {
    res.write(`event: ping\ndata: {}\n\n`);
    if (res.flush) res.flush();
  }, 15000);

  req.on("close", () => {
    clearInterval(ping);
    clients = clients.filter(c => c !== res);
    console.log(`❌ SSE client disconnected (${clients.length} remaining)`);
  });
});

export function broadcastAgentUpdate(update: any) {
  console.log("📡 broadcastAgentUpdate:", update);
  for (const c of clients) {
    c.write(`event: agent\ndata: ${JSON.stringify(update)}\n\n`);
    if (c.flush) c.flush();
  }
}

export function broadcastLogUpdate(update: any) {
  console.log("�� broadcastLogUpdate:", update);
  for (const c of clients) {
    c.write(`event: log\ndata: ${JSON.stringify(update)}\n\n`);
    if (c.flush) c.flush();
  }
}

export default router;
