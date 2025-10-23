import { Router, Request, Response } from "express";

const router = Router();
const globalAny = global as any;

if (!globalAny.__EVENTS_CLIENTS__) {
  globalAny.__EVENTS_CLIENTS__ = [];
}
let clients: Response[] = globalAny.__EVENTS_CLIENTS__;

router.get("/", (req: Request, res: Response) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();

  clients.push(res);
  console.log(`🔌 SSE client connected (${clients.length} total)`);

  const ping = setInterval(() => res.write("event: ping\ndata: {}\n\n"), 15000);
  req.on("close", () => {
    clearInterval(ping);
    clients = clients.filter(c => c !== res);
    console.log(`❌ SSE client disconnected (${clients.length} remaining)`);
  });
});

function broadcast(event: string, data: any) {
  const payload = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
  clients.forEach(c => c.write(payload));
  console.log(`📡 Broadcast [${event}] → ${clients.length} client(s)`);
}

export const broker = { broadcast };
export default router;
