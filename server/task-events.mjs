import pg from "pg";

const url =
  process.env.DATABASE_URL ||
  process.env.POSTGRES_URL ||
  process.env.POSTGRES_URI ||
  process.env.POSTGRES_CONNECTION_STRING;

if (!url) throw new Error("Missing DATABASE_URL/POSTGRES_URL");

const pool = new pg.Pool({ connectionString: url });

export async function appendTaskEvent(kind, payload) {
  const client = await pool.connect();
  try {
    await client.query(
      "insert into public.task_events (kind, payload) values ($1, $2)",
      [kind, JSON.stringify(payload ?? {})]
    );
  } finally {
    client.release();
  }
}
