// <0001fac5> reflections-all: compatible Drizzle select query
import { db } from "../../db/client";
import { reflections } from "../../db/schema";

export async function reflectionsAllHandler(_req, res) {
  console.log("🪞 reflectionsAllHandler called");
  try {
    const rows = await db.select({
      id: reflections.id,
      created_at: reflections.created_at,
      summary: reflections.summary
    }).from(reflections).orderBy(reflections.created_at);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
}
