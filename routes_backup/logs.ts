import express, { Request, Response } from "express";
const router = express.Router();






import { desc, sql } from "drizzle-orm";
import { task_events } from "../db/audit";


// 🎯 Return recent log-like events (non-task types or system messages)
  try {
    const rows = await db
      .select()
      .from(task_events)
      .where(sql`type IN ('ui_log_test','agent_sync','system_log','reflection')`)
      .orderBy(desc(task_events.created_at))
      .limit(10);

    reson(rows);
  } catch (err) {
    console.error("❌ /logs/recent failed:", err);
    res.status(500)on({ error: "Failed to load logs" });
  }
});

