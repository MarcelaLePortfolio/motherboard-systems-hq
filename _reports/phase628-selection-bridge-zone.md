# Phase 628 Selection Bridge Patch Zone

## dashboard task render zone
    const res = await fetch(url, {
      method: opts.method || "GET",
      headers: { "Content-Type": "application/json" },
      body: opts.body ? JSON.stringify(opts.body) : undefined,
    });
    const json = await res.json();
    if (!res.ok) throw new Error(json?.error || "Request failed");
    return json;
  }

  function render() {
    const ui = ensureShell();
    if (!ui) return;

    if (ui.errorEl) {
      ui.errorEl.innerHTML = state.lastError
        ? `<div style="color:red">${esc(state.lastError)}</div>`
        : "";
    }

    if (ui.listEl) {
      ui.listEl.innerHTML = `
        <div>
          ${state.loading && !state.tasks.length ? `<div style="opacity:.7">Loading…</div>` : ""}
          ${
            state.tasks.length
              ? state.tasks
                  .map(
                    (t) => `
              <div style="display:flex;justify-content:space-between;gap:8px">
                <span>${esc(t.title)}</span>
                ${
                  ["complete", "completed", "done"].includes(String(t.status || "").toLowerCase())
                    ? `<span style="opacity:.5;font-size:12px">Completed</span>`
                    : `<button data-id="${esc(t.id)}">Complete</button>`
                }
              </div>
              ${renderGuidance(t)}
            `
                  )
                  .join("")
              : !state.loading
              ? `<div style="opacity:.7">No tasks found.</div>`
              : ""
          }
        </div>
      `;

      ui.listEl.querySelectorAll("button[data-id]").forEach((btn) => {
        btn.onclick = () => completeTask(btn.dataset.id);
      });
    }

    if (ui.runsHost && !state.runsPanelMounted) {
      try {
        renderRunsPanel(ui.runsHost);

## inspector render/filter zone

  function normalize(data) {
    return data?.tasks || data?.rows || data?.data || [];
  }

  function renderGuidance(r) {
    const g = r && r.guidance;
    if (!g) return "";
    const classification = g.classification || "guidance";
    const outcome = g.outcome || "";
    const explanation = g.explanation || "";
    return `<div style="margin-top:6px;font-size:11px;color:#fde68a"><strong>Guidance:</strong> ${classification}${outcome ? " — " + outcome : ""}${explanation ? `<details style="margin-top:3px;"><summary style="cursor:pointer;">Guidance details</summary><div style="color:#bfdbfe">${explanation}</div></details>` : ""}</div>`;
  }

  function render(rows) {
    const el = mountInspector();
    if (!el) return;

    if (!rows || !rows.length) {
      el.innerHTML = `
        <div style="opacity:.6;font-size:12px">
          No execution data available
        </div>`;
      return;
    }

    el.innerHTML = rows.map(r => {
      const title = r.title || r.task || "(untitled)";
      const status = r.status || "unknown";
      const id = r.task_id || r.id || "—";

      const outcome = r.outcome_preview || "";
      const explanation = r.explanation_preview || "";

      return `
        <div style="padding:8px;border-bottom:1px solid rgba(255,255,255,0.06)">
          <div style="font-size:12px">${title}</div>
          <div style="font-size:11px;opacity:.6">
            status: ${status} | id: ${id}
          </div>
          ${outcome ? `<div style="margin-top:6px;font-size:11px;color:#d1fae5"><strong>Outcome:</strong> ${outcome}</div>` : ""}
          ${explanation ? `<div style="margin-top:3px;font-size:11px;color:#bfdbfe"><strong>Explanation:</strong> ${explanation}</div>` : ""}
          ${renderGuidance(r)}
        </div>
      `;
    }).join("");
  }

  async function tick() {
    try {
      const res = await fetch(INSPECTOR_ENDPOINT, { cache: "no-store" });
      const data = await res.json();

      render(normalize(data));

      console.log("[execution-inspector] rendered rows:", normalize(data).length);
    } catch (e) {
      console.log("[execution-inspector] fetch error", e);
    }
  }

