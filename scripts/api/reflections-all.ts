// <0001fab1> API Route – /api/reflections/all
// Returns the complete history of Cade's reflections from db/local.sqlite

import { dbPromise } from "../../db/client";

export default async function handler(req, res) {
  try {
    const db = await dbPromise;
    const results = db
      .prepare("SELECT id, created_at, summary FROM reflections ORDER BY created_at DESC")
      .all();

    const parsed = results.map(r => ({
      ...r,
      summary: JSON.parse(r.summary || "{}"),
    }));

    res.json(parsed);
  } catch (err) {
    console.error("❌ Failed to fetch reflection history:", err);
    res.status(500).json({ error: "Internal Server Error" });
  }
}
