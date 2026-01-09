/**
 * Phase 23: TaskSpec -> existing /api/tasks-mutations/delegate adapter
 *
 * Input:
 * { task: { target:"cade"|"effie"|"atlas", title?:string, spec?:any, task_id?:string } }
 *
 * Output: pass through existing delegate JSON response
 */
export async function handleDelegateTaskSpec(req, res) {
  try {
    const body = req.body ?? {};
    const task = body.task ?? body;
    const target = String(task?.target || "").toLowerCase();
    if (!["cade", "effie", "atlas"].includes(target)) {
      return res.status(400).json({ ok: false, error: "invalid_target", details: "target must be cade|effie|atlas" });
    }

    // Convert to existing delegate payload shape (agent + title + notes + meta)
    const payload = {
      agent: target,
      title: String(task?.title || "(untitled)"),
      notes: "",
      source: "matilda",
      meta: {
        taskspec: task?.spec ?? null,
        task_id: task?.task_id ?? null,
      },
    };

    // Call the local server route handler by proxying fetch to itself
    const u = new URL(req.originalUrl, `http://${req.headers.host}`);
    const base = `${u.protocol}//${u.host}`;

    const r = await fetch(`${base}/api/tasks-mutations/delegate`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    const json = await r.json().catch(() => ({}));
    return res.status(r.status).json(json);
  } catch (err) {
    return res.status(500).json({ ok: false, error: "delegate_taskspec_failed", details: String(err?.message || err) });
  }
}
