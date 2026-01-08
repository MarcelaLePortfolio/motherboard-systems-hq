import express from "express";
import { pool } from "../db/pool.mjs";

const router = express.Router();

router.get("/events/task-events", async (req, res) => {
  res.status(200);
  res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("X-Accel-Buffering", "no");
  res.flushHeaders?.();

  // hello
  res.write(`event: hello\ndata: {"kind":"task-events"}\n\n`);

  // TODO (Phase 20):
  // - read cursor from Last-Event-ID or ?after=
  // - stream task_events ordered by id ASC
  // - poll with backoff OR LISTEN/NOTIFY
  // - emit `event: task.event` per row
  // - cleanup on close

  const onClose = () => {
    // cleanup hooks
  };
  req.on("close", onClose);
});

export default router;
