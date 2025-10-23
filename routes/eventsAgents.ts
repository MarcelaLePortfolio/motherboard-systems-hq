import { Router, Request, Response } from "express";

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

function broadcast(event: string, data: any) {
  clients.forEach(res => res.write(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`));
  console.log(`📡 Broadcast [${event}] → ${clients.length} client(s)`);
}

export const broker = { broadcast };
export default router;
