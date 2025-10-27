import express from "express";
import cors from "cors";
import path from "path";
import { EventEmitter } from "events";
import { router as matildaRouter } from "./routes/matilda";

export const emitter = new EventEmitter();

const app = express();
app.use(cors());
app.use(express.json());
app.use("/matilda", matildaRouter);

// SSE stream route
app.get("/events", (req, res) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();

  const send = (data: any) => res.write(`data: ${JSON.stringify(data)}\n\n`);
  emitter.on("update", send);

  req.on("close", () => emitter.removeListener("update", send));
});

export function broadcast(message: string) {
  console.log(message);
  emitter.emit("update", { message, timestamp: new Date().toISOString() });
}

const publicDir = path.join(process.cwd(), "public");
app.use(express.static(publicDir));
console.log(`📦 Static files served from ${publicDir}`);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`🚀 Server running at http://localhost:${PORT}`));
