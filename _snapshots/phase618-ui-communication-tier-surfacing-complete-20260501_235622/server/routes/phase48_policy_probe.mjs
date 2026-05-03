/**
 * Phase 48 — deterministic enforcement probe
 * POST /api/policy/probe
 * - 201 when POLICY_ENFORCE_ENABLED is falsey (and performs a minimal DB write)
 * - 403 when POLICY_ENFORCE_ENABLED is truthy
 */
import { pool } from "../db.js";

function isTrue(v) {
  const s = String(v || "").trim().toLowerCase();
  return s === "1" || s === "true" || s === "yes";
}

export function registerPhase48PolicyProbe(app) {
  app.post("/api/policy/probe", async (req, res) => {
    const enforce = isTrue(process.env.POLICY_ENFORCE_ENABLED);
    if (enforce) {
      return res.status(403).json({ ok: false, blocked: true, reason: "policy_enforce_enabled" });
    }

    // Minimal allow-path write proving DB mutation.
    // Match current schema:
    // tasks(task_id, title, status, run_id, action_tier, notes, updated_at, ...)
    // task_events(kind, payload, created_at, task_id, run_id, actor, ts, ...)
    const run_id = "policy.probe.run";
    const task_id = "policy.probe.task";
    const title = "policy.probe";
    const notes = "probe allow-path write";
    const actor = "policy.probe";
    const ts = Date.now();
    const kind = "policy.probe.allowed";
    const payload = { ok: true, probe: true, nonce: ts };

    await pool.query(
      `
      insert into tasks (task_id, title, status, run_id, action_tier, notes)
      values ($1, $2, 'queued', $3, 'A', $4)
      on conflict (task_id) do update set
        title = excluded.title,
        run_id = excluded.run_id,
        notes = excluded.notes,
        updated_at = now()
      `,
      [task_id, title, run_id, notes]
    );

    await pool.query(
      `
      insert into task_events(kind, task_id, run_id, actor, ts, payload)
      values ($1::text, $2::text, $3::text, $4::text, $5::bigint, $6::jsonb)
      `,
      [kind, task_id, run_id, actor, ts, payload]
    );

    return res.status(201).json({ ok: true, blocked: false });
  });
}
