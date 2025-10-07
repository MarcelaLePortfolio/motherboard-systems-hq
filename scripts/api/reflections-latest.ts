// <0001fb37> reflections-latest handler using async dbPromise
import { dbPromise } from "../../db/client";
import { reflections } from "../../db/schema";

export async function reflectionsLatestHandler(_req, res) {
  console.log("🪞 reflectionsLatestHandler called");
  try {
    const db = await dbPromise;
    const [row] = await db
      .select({
        id: reflections.id,
        created_at: reflections.created_at,
        summary: reflections.summary,
      })
      .from(reflections)
      .orderBy(reflections.created_at)
      .limit(1);
    res.json(row || {});
  } catch (err) {
    console.error("❌ reflectionsLatestHandler error:", err);
    res.status(500).json({ error: String(err) });
  }
}
