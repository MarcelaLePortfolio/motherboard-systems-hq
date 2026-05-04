export async function waitForPostgresReady(pool, {
  timeoutMs = 60_000,
  intervalMs = 250,
  logEveryMs = 2_000,
} = {}) {
  const start = Date.now();
  let lastLog = 0;
  // retryable PG error codes we commonly see during startup
  const retryCodes = new Set([
    "ECONNREFUSED",
    "57P03", // cannot_connect_now
    "53300", // too_many_connections
    "3D000", // invalid_catalog_name (db not created yet)
  ]);

  while (true) {
    try {
      // pg-pool: connect then release, or just query
      await pool.query("select 1 as ok");
      return;
    } catch (err) {
      const code = err?.code || err?.errno || err?.cause?.code;
      const msg = String(err?.message || err);
      const elapsed = Date.now() - start;

      const isRetry =
        retryCodes.has(String(code)) ||
        /ECONNREFUSED/i.test(msg) ||
        /connect/i.test(msg) ||
        /Connection terminated/i.test(msg);

      if (!isRetry || elapsed > timeoutMs) {
        // surface the real boot failure if it isn't "not ready yet"
        throw err;
      }

      if (Date.now() - lastLog > logEveryMs) {
        lastLog = Date.now();
        console.log(`[db] waiting for postgres... elapsed=${elapsed}ms code=${code ?? "?"}`);
      }

      await new Promise(r => setTimeout(r, intervalMs));
    }
  }
}
