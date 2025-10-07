// <0001fb36> reflections-all handler using async dbPromise
import { dbPromise } from "../../db/client";
import { reflections } from "../../db/schema";

export async function reflectionsAllHandler(_req, res) {
  console.log("🪞 reflectionsAllHandler called");
  try {
    const db = await dbPromise;
    const rows = await db
      .select({
        id: reflections.id,
        created_at: reflections.created_at,
        summary: reflections.summary,
      })
      .from(reflections)
      .orderBy(reflections.created_at);
    res.json(rows);
  } catch (err) {
    console.error("❌ reflectionsAllHandler error:", err);
    res.status(500).json({ error: String(err) });
  }
}
