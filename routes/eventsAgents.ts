import { Router, Request, Response } from "express";

type Client = Response;

class SSEBroker {
  clients: Client[] = [];

  addClient(res: Client) {
    this.clients.push(res);
    console.log(`🔌 SSE client connected (${this.clients.length} total)`);
  }

  removeClient(res: Client) {
    this.clients = this.clients.filter(c => c !== res);
    console.log(`❌ SSE client disconnected (${this.clients.length} remaining)`);
  }

  broadcast(event: string, data: any) {
    console.log(`📡 Broadcast [${event}] → ${this.clients.length} client(s)`);
    const payload = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
    this.clients.forEach(c => c.write(payload));
  }
}

// ✅ Attach singleton instance globally
const globalAny = global as any;
if (!globalAny.__SSE_BROKER__) {
  globalAny.__SSE_BROKER__ = new SSEBroker();
}
const broker: SSEBroker = globalAny.__SSE_BROKER__;

const router = Router();
router.get("/", (req: Request, res: Response) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();

  broker.addClient(res);

  const ping = setInterval(() => res.write("event: ping\ndata: {}\n\n"), 15000);
  res.on("close", () => {
    clearInterval(ping);
    broker.removeClient(res);
  });
});

export function broadcastLogUpdate(update: any) {
  broker.broadcast("log", update);
}
export function broadcastAgentUpdate(update: any) {
  broker.broadcast("agent", update);
}

export default router;
