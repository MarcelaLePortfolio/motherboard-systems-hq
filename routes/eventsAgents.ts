import { Router, Request, Response } from "express";
import { broker } from "./sseBroker";

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
