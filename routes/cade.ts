
import express from "express";


const router = express.Router();

router.get("/recent", async (req, res) => {

  try {

    const rows = sqlite

      .prepare(`

        SELECT *

        FROM task_events

        WHERE agent = ?

        ORDER BY created_at DESC

        LIMIT 10

      `)

      .all("Cade");

    res.json(rows);

  } catch (err) {

    console.error("❌ Error fetching Cade events:", err);

    res.status(500).json({ error: "Failed to fetch Cade events" });

  }

});

export default router;

