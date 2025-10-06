// <0001fab8> CommonJS-compatible reflections-latest handler

import { dbPromise } from "../../db/client";

export async function reflectionsLatestHandler(req, res) {
  try {
    const db = await dbPromise;
    const result = db
      .prepare("SELECT id, created_at, summary FROM reflections ORDER BY created_at DESC LIMIT 1")
      .get();

    if (!result) {
      return res.status(404).json({ message: "No reflections found" });
    }

    const parsed = {
      ...result,
      summary: JSON.parse(result.summary || "{}"),
    };

    res.json(parsed);
  } catch (err) {
    console.error("❌ Failed to fetch latest reflection:", err);
    res.status(500).json({ error: "Internal Server Error" });
  }
}
