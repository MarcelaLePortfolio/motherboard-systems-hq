import express from "express";
import { db } from "../db/client.ts";
export const router = express.Router();

router.get("/", (req, res) => {
  const rows = db.prepare("SELECT * FROM task_events ORDER BY created_at DESC LIMIT 20").all();
  res.json({ feed: rows });
});
