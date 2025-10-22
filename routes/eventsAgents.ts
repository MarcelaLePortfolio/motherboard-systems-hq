import { Router, Request, Response } from "express";

class SSEBroker {
  private static _instance: SSEBroker;
  private clients: Response[] = [];

  private constructor() {}

  static get instance() {
    if (!this._instance) this._instance = new SSEBroker();
    return this._instance;
  }

  addClient(res: Response) {
    this.clients.push(res);
    console.log(`🔌 SSE client connected (${this.clients.length} total)`);
    res.on("close", () => {
      this.clients = this.clients.filter(c => c !== res);
      console.log(`❌ SSE client disconnected (${this.clients.length} remaining)`);
    });
  }

  broadcast(event: string, data: any) {
    console.log(`📡 Broadcast [${event}] → ${this.clients.length} client(s)`);
    const payload = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
    this.clients.forEach(c => c.write(payload));
  }
}

const router = Router();

router.get("/", (req: Request, res: Response) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();
  SSEBroker.instance.addClient(res);
  // keep connection alive
  const ping = setInterval(() => res.write("event: ping\ndata: {}\n\n"), 15000);
  req.on("close", () => clearInterval(ping));
});

export const broker = SSEBroker.instance;
export function broadcastLogUpdate(update: any) {
  broker.broadcast("log", update);
}
export function broadcastAgentUpdate(update: any) {
  broker.broadcast("agent", update);
}
export default router;
