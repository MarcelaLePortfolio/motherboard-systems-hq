import { NextResponse } from "next/server";
import { Pool } from "pg";

declare global {
  // eslint-disable-next-line no-var
  var __RUNVIEW_POOL: Pool | undefined;
}

function getPool(): Pool {
  const url = process.env.POSTGRES_URL || process.env.DATABASE_URL;
  if (!url) throw new Error("Missing POSTGRES_URL (or DATABASE_URL)");

  if (!globalThis.__RUNVIEW_POOL) {
    globalThis.__RUNVIEW_POOL = new Pool({
      connectionString: url,
      max: 5,
      idleTimeoutMillis: 30_000,
    });
  }
  return globalThis.__RUNVIEW_POOL;
}

export async function GET(
  _req: Request,
  ctx: { params: Promise<{ run_id: string }> }
) {
  const { run_id } = await ctx.params;

  if (!run_id || typeof run_id !== "string") {
    return NextResponse.json({ error: "run_id required" }, { status: 400 });
  }

  const pool = getPool();
  const q = `
    SELECT *
    FROM run_view
    WHERE run_id = $1
    LIMIT 1
  `;

  try {
    const r = await pool.query(q, [run_id]);
    if (r.rows.length === 0) {
      return NextResponse.json({ error: "not_found", run_id }, { status: 404 });
    }
    return NextResponse.json(r.rows[0], { status: 200 });
  } catch (e: any) {
    return NextResponse.json(
      { error: "query_failed", detail: String(e?.message || e) },
      { status: 500 }
    );
  }
}
