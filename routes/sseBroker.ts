import { Response } from "express";

type Client = Response;

class SSEBroker {
  clients: Client[] = [];

  addClient(res: Client) {
    this.clients.push(res);
    console.log(`🔌 SSE client connected (${this.clients.length} total)`);
    res.on("close", () => this.removeClient(res));
  }

  removeClient(res: Client) {
    this.clients = this.clients.filter(c => c !== res);
    console.log(`❌ SSE client disconnected (${this.clients.length} remaining)`);
  }

  broadcast(event: string, data: any) {
    const payload = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
    this.clients.forEach(c => c.write(payload));
    console.log(`📡 Broadcast [${event}] → ${this.clients.length} client(s)`);
  }
}

// ✅ Global singleton to prevent ESM duplication
const globalAny = global as any;
if (!globalAny.__SSE_BROKER__) globalAny.__SSE_BROKER__ = new SSEBroker();
export const broker: SSEBroker = globalAny.__SSE_BROKER__;
