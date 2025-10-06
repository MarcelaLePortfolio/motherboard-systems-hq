// <0001fab7> CommonJS-compatible reflections-all handler

import { dbPromise } from "../../db/client";

export async function reflectionsAllHandler(req, res) {
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
