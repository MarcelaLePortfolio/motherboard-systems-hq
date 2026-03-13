import { randomUUID } from "node:crypto";

export async function insertTaskMutation(pool, body = {}) {
  const task_id = body.task_id || `task.${randomUUID()}`;
  const title = body.title || "Delegated task";
  const status = "queued";
  const notes = body.notes || "";
  const run_id = body.run_id || null;
  const action_tier = body.action_tier || "A";
  const kind = body.kind || "delegated";

  const payload = {
    agent: body.agent || "cade",
    source: body.source || "dashboard",
    meta: body.meta || {}
  };

  const result = await pool.query(
  `insert into tasks (
    task_id,
    title,
    status,
    notes,
    run_id,
    action_tier,
    kind,
    payload
  )
  values ($1,$2,$3,$4,$5,$6,$7,$8::jsonb)
  returning id::text,task_id,title,status,notes,run_id,action_tier,kind,payload,created_at,updated_at`,
  [
    task_id,
    title,
    status,
    notes,
    run_id,
    action_tier,
    kind,
    JSON.stringify(payload)
  ]);

  return result.rows[0];
}
