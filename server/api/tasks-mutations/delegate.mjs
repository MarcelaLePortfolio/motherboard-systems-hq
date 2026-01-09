import crypto from "crypto";

export async function handleDelegate(req, res, deps) {
  try {
    const body = req.body ?? {};
    const task = body.task ?? body;

    const target = String(task?.target || "").toLowerCase();
    if (!["cade", "effie", "atlas"].includes(target)) {
      return res.status(400).json({ ok: false, error: "invalid_target", details: "target must be cade|effie|atlas" });
    }

    const task_id = String(task?.task_id || crypto.randomUUID());
    const title = String(task?.title || "Delegated Task");
    const spec = task?.spec ?? task;

    const payload = {
      ts: Date.now(),
      task_id,
      target,
      title,
      spec,
      source: "matilda",
    };

    const db = deps?.db;
    if (!db?.query) {
      return res.status(500).json({ ok: false, error: "missing_db", details: "db pool not available" });
    }

    await db.query(
      `insert into task_events(kind,payload) values ($1,$2::jsonb)`,
      ["task.created", JSON.stringify(payload)]
    );

    return res.status(200).json({ ok: true, task_id });
  } catch (err) {
    return res.status(500).json({ ok: false, error: "delegate_failed", details: String(err?.message || err) });
  }
}
