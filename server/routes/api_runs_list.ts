import type { Request, Response } from "express";
import { pool } from "../db";

const DEFAULT_LIMIT = 50;
const MAX_LIMIT = 200;

export async function getRunsList(req: Request, res: Response) {
  const rawLimit = Number(req.query.limit ?? DEFAULT_LIMIT);
  const limit =
    Number.isFinite(rawLimit) && rawLimit > 0
      ? Math.min(rawLimit, MAX_LIMIT)
      : DEFAULT_LIMIT;

  const sql = `
    SELECT *
    FROM run_view
    ORDER BY created_at DESC, run_id DESC
    LIMIT $1
  `;

  try {
    const { rows } = await pool.query(sql, [limit]);
    res.status(200).json(rows);
  } catch (err) {
    console.error("GET /api/runs failed", err);
    res.status(500).json({ error: "internal_error" });
  }
}
