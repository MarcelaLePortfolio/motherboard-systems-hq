// <0001fac6> reflections-latest: compatible Drizzle select query (LIMIT 1)
import { db } from "../../db/client";
import { reflections } from "../../db/schema";

export async function reflectionsLatestHandler(_req, res) {
  try {
    const [row] = await db.select({
      id: reflections.id,
      created_at: reflections.created_at,
      summary: reflections.summary
    }).from(reflections).orderBy(reflections.created_at).limit(1);
    res.json(row || {});
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
}
