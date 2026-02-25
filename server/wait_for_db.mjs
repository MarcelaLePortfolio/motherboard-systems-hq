import { pool } from "./db_pool.mjs";

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export async function waitForDbReady({
  attempts = 60,
  delayMs = 500,
  label = "db",
} = {}) {
  let lastErr;
  for (let i = 1; i <= attempts; i++) {
    try {
      const client = await pool.connect();
      try {
        await client.query("select 1 as ok");
      } finally {
        client.release();
      }
      console.log(`[boot] ${label} ready after ${i}/${attempts}`);
      return;
    } catch (err) {
      lastErr = err;
      const msg = (err && err.message) ? err.message : String(err);
      console.log(`[boot] ${label} not ready (${i}/${attempts}): ${msg}`);
      await sleep(delayMs);
    }
  }
  throw lastErr ?? new Error("db not ready");
}
