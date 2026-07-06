
import express from "express";

import { sqlite } from "../db/client.js";

const router = express.Router();

router.get("/recent", async (req, res) => {

  try {

    const rows = sqlite

      .prepare(`

        SELECT *

        FROM task_events

        ORDER BY created_at DESC

        LIMIT 10

      `)

      .all();

    res.json({

      rowCount: rows.length,

      rows

    });

  } catch (err) {

    console.error("❌ tasks recent failed:", err);

    res.status(500).json({ error: "failed to fetch tasks" });

  }

});

export default router;

