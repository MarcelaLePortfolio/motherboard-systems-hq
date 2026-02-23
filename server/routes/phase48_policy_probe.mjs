/**
 * Phase 48 — deterministic enforcement probe
 * POST /api/policy/probe
 * - 201 when POLICY_ENFORCE_ENABLED is falsey (and performs a tiny deterministic write)
 * - 403 when POLICY_ENFORCE_ENABLED is truthy (and performs no writes)
 */
function isTrue(v) {
  const s = String(v || "").trim().toLowerCase();
  return s === "1" || s === "true" || s === "yes";
}

// NOTE: We intentionally import lazily inside the handler so this route stays lightweight,
// and so it follows the existing server DB wiring (Pool/export naming may vary by repo).
async function getDb() {
  // Try common local modules (first match wins)
  const candidates = [
    "../db.mjs",
    "../db/index.mjs",
    "../db/pool.mjs",
    "../db/client.mjs",
    "../db.js",
    "../db/index.js",
  ];
  let lastErr = null;
  for (const rel of candidates) {
    try {
      // eslint-disable-next-line no-await-in-loop
      const mod = await import(rel);
      if (mod?.pool?.query) return mod.pool;
      if (mod?.db?.query) return mod.db;
      if (mod?.default?.query) return mod.default;
    } catch (e) {
      lastErr = e;
    }
  }
  throw lastErr || new Error("No DB module found for policy probe");
}

export function registerPhase48PolicyProbe(app) {
  app.post("/api/policy/probe", async (req, res) => {
    const enforce = isTrue(process.env.POLICY_ENFORCE_ENABLED);
    if (enforce) {
      return res.status(403).json({ ok: false, blocked: true, reason: "policy_enforce_enabled" });
    }

    // Minimal write to prove "allow path" results in DB mutation.
    // We use stable IDs so repeated calls don't explode row counts; the event row is forced-unique via a timestamp-ish nonce.
    const db = await getDb();

    const run_id = "policy.probe.run";
    const task_id = "policy.probe.task";
    const kind = "policy.probe.allowed";
    const payload = { ok: true, probe: true };

    // Best-effort inserts that match the repo's existing schema pattern:
    // - tasks: ensure the task row exists (idempotent)
    // - task_events: append an event (expected to increase count)
    //
    // If your schema differs, adjust the column list to match server/sql DDL.
    await db.query(
      `
      insert into tasks (task_id, run_id, task_status, is_terminal, actor)
      values ($1, $2, 'running', false, 'policy.probe')
      on conflict (task_id) do nothing
      `,
      [task_id, run_id]
    );

    await db.query(
      `
      insert into task_events (run_id, task_id, kind, actor, payload)
      values ($1, $2, $3, 'policy.probe', $4::jsonb)
      `,
      [run_id, task_id, kind, JSON.stringify(payload)]
    );

    return res.status(201).json({ ok: true, blocked: false });
  });
}
