import Database from "better-sqlite3";
console.log("<0001f9ed> Active tasksRouter loaded from:", import.meta.url);
import express from "express";
import path from "path";
import fs from "fs";
import { db } from "../db/client";
import { task_events } from "../db/audit";
import { desc } from "drizzle-orm";
export const tasksRouter = express.Router();
tasksRouter.get("/recent", async (_req, res) => {
    console.log("<0001f9f3> 🚀 /tasks/recent endpoint triggered");
    const dbPath = path.resolve(process.cwd(), "motherboard.sqlite");
    const exists = fs.existsSync(dbPath);
    const size = exists ? fs.statSync(dbPath).size : 0;
    let rows = [];
    try {
        rows = db.select().from(task_events).orderBy(desc(task_events.created_at)).limit(10).all();
    }
    catch (err) {
        console.error("❌ Query failed:", err);
    }
    console.log("<0001f9f0> ⚡ Entering fallback check...");
    const direct = new Database(dbPath);
    console.log("<0001f9f1> 🧩 Direct SQLite path:", dbPath);
    const raw = direct.prepare("SELECT * FROM task_events ORDER BY created_at DESC LIMIT 5").all();
    console.log("<0001f9f2> ✅ Fallback query executed");
    console.log("<0001f9ef> Direct SQLite query returned", raw.length, "rows");
    res.json({ cwd: process.cwd(), dbPath, exists, size, rowCount: rows.length, rows });
});
