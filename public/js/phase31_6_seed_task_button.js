/*
Phase 31.6 — Manual seed task button (dev-only UX)

- Looks for #seedTaskBtn; no-op if absent.
- Tries a few likely task-create endpoints in order.
- Shows success/failure with status code so you can see what's happening.
*/
(() => {
  function $(id) { return document.getElementById(id); }
  const btn = $("seedTaskBtn");
  if (!btn) return;

  const endpoints = [
    "/api/tasks",
    "/api/tasks-postgres",
    "/api/tasks/create",
  ];

  function toast(msg, ok = true) {
    try {
      const el = document.createElement("div");
      el.className =
        "fixed bottom-4 right-4 z-[9999] max-w-[520px] text-sm px-4 py-3 rounded-2xl border " +
        (ok
          ? "bg-emerald-500/15 border-emerald-300/20 text-emerald-100"
          : "bg-rose-500/15 border-rose-300/20 text-rose-100");
      el.textContent = msg;
      document.body.appendChild(el);
      setTimeout(() => el.remove(), 4200);
    } catch {}
  }

  async function postJSON(url, body) {
    const res = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    const text = await res.text().catch(() => "");
    return { ok: res.ok, status: res.status, text };
  }

  async function seedOnce() {
    const now = Date.now();
    const body = {
      kind: "demo.seed",
      type: "demo.seed",
      name: "phase31.6 seed task",
      title: "phase31.6 seed task",
      payload: {
        ts: now,
        msg: "seeded from dashboard button",
        source: "public/js/phase31_6_seed_task_button.js",
      },
      meta: {
        ts: now,
        actor: "dashboard",
        note: "manual seed task",
      },
    };

    let last = null;
    for (const url of endpoints) {
      try {
        const r = await postJSON(url, body);
        last = { url, ...r };
        if (r.ok) {
          toast(`Seed task created via ${url} (HTTP ${r.status})`);
          return true;
        }
      } catch (e) {
        last = { url, ok: false, status: 0, text: String(e || "") };
      }
    }

    const tail = last ? ` last=${last.url} HTTP ${last.status}` : "";
    toast(`Seed task failed (no endpoint OK).${tail}`, false);
    try { console.warn("[phase31.6] seed failed details:", last); } catch {}
    return false;
  }

  btn.addEventListener("click", async () => {
    const oldText = btn.textContent || "Seed Task";
    try {
      btn.disabled = true;
      btn.dataset.loading = "1";
      btn.textContent = "Seeding...";
      await seedOnce();
    } finally {
      btn.disabled = false;
      btn.dataset.loading = "0";
      btn.textContent = oldText;
    }
  });
})();
