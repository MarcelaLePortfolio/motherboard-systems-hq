import type { Request, Response } from "express";

export function eventsRoute(req: Request, res: Response) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream; charset=utf-8",
    "Cache-Control": "no-cache, no-transform",
    Connection: "keep-alive",
  });

  res.write(`: connected\n\n`);

  const send = (event: string, data: any) => {
    res.write(`event: ${event}\n`);
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  };

  send("ping", { ts: Date.now() });

  const agents: any[] = [];
  send("agent", { agents });

  const interval = setInterval(() => {
    send("ping", { ts: Date.now() });
  }, 15000);

  req.on("close", () => {
    clearInterval(interval);
    res.end();
  });
}
