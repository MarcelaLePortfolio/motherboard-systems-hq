import express from "express";
import { desc } from "drizzle-orm";
import { reflection_index } from "../db/reflection_index";

export const reflectionsRouter = express.Router();

reflectionsRouter.get("/recent", async (_req, res) => {
  try {
    const rows = db
      .select()
      .from(reflection_index)
      .orderBy(desc(reflection_index.created_at))
      .limit(10)
      .all();
    reson(rows);
  } catch (err: any) {
    console.error("Error fetching reflections:", err);
    res.status(500)on({ error: (err as any).message });
  }
});

export default reflectionsRouter;
