(() => {
  const PANEL_ID = "mb-task-events-panel";
  const FEED_ID = "mb-task-events-feed";
  const CARD_ID = "mb-probe-lifecycle-card";
  const STATE_ID = "mb-probe-lifecycle-state";
  const META_ID = "mb-probe-lifecycle-meta";
  const STEPS_ID = "mb-probe-lifecycle-steps";
  const RUNS_API = "/api/runs";
  const PROBE_RUN_ID = "policy.probe.run";

  const state = {
    runId: PROBE_RUN_ID,
    status: "idle",
    eventCount: 0,
    lastTs: null,
    lastKind: null,
    started: false,
    running: false,
    completed: false,
    failed: false,
  };

  function fmtFull(ts) {
    return typeof ts === "number" && Number.isFinite(ts)
      ? new Date(ts).toLocaleString()
      : "—";
  }

  function getVisual(status) {
    if (status === "completed") {
      return {
        label: "Completed",
        border: "rgba(34,197,94,0.34)",
        background: "rgba(34,197,94,0.10)",
        badge: "rgba(34,197,94,0.16)",
      };
    }

    if (status === "failed") {
      return {
        label: "Failed",
        border: "rgba(239,68,68,0.34)",
        background: "rgba(239,68,68,0.10)",
        badge: "rgba(239,68,68,0.16)",
      };
    }

    if (status === "running") {
      return {
        label: "Running",
        border: "rgba(99,102,241,0.34)",
        background: "rgba(79,70,229,0.12)",
        badge: "rgba(99,102,241,0.16)",
      };
    }

    if (status === "started") {
      return {
        label: "Started",
        border: "rgba(59,130,246,0.34)",
        background: "rgba(59,130,246,0.10)",
        badge: "rgba(59,130,246,0.16)",
      };
    }

    return {
      label: "Idle",
      border: "rgba(148,163,184,0.24)",
      background: "rgba(255,255,255,0.03)",
      badge: "rgba(148,163,184,0.16)",
    };
  }

  function inferStatusFromKind(kind, currentStatus) {
    const k = String(kind || "");

    if (
      k === "task.failed" ||
      k === "policy.probe.denied" ||
      k === "policy.probe.blocked" ||
      k === "policy.probe.failed"
    ) {
      return "failed";
    }

    if (k === "task.completed" || k === "policy.probe.completed") {
      return "completed";
    }

    if (
      k === "task.running" ||
      k === "policy.probe.allowed" ||
      k === "policy.probe.running" ||
      k === "policy.probe.visible"
    ) {
      return "running";
    }

    if (
      k === "task.created" ||
      k === "task.started" ||
      k === "policy.probe.started"
    ) {
      return "started";
    }

    return currentStatus === "idle" ? "started" : currentStatus;
  }

  function ensureCard() {
    const panel = document.getElementById(PANEL_ID);
    const feed = document.getElementById(FEED_ID);
    if (!panel || !feed) return null;

    let card = document.getElementById(CARD_ID);
    if (card) return card;

    card = document.createElement("section");
    card.id = CARD_ID;
    card.style.margin = "14px 16px 0";
    card.style.border = "1px solid rgba(148,163,184,0.24)";
    card.style.borderRadius = "16px";
    card.style.padding = "12px 14px";
    card.style.background = "rgba(255,255,255,0.03)";
    card.style.boxShadow = "inset 0 1px 0 rgba(255,255,255,0.03)";

    const top = document.createElement("div");
    top.style.display = "flex";
    top.style.alignItems = "center";
    top.style.justifyContent = "space-between";
    top.style.gap = "12px";

    const titleWrap = document.createElement("div");
    titleWrap.style.minWidth = "0";

    const title = document.createElement("div");
    title.textContent = "Probe lifecycle";
    title.style.fontSize = "13px";
    title.style.fontWeight = "700";
    title.style.letterSpacing = "0.02em";

    const badge = document.createElement("div");
    badge.id = STATE_ID;
    badge.style.marginTop = "6px";
    badge.style.display = "inline-flex";
    badge.style.alignItems = "center";
    badge.style.gap = "6px";
    badge.style.padding = "4px 8px";
    badge.style.borderRadius = "999px";
    badge.style.fontSize = "11px";
    badge.style.fontWeight = "700";
    badge.style.letterSpacing = "0.03em";
    badge.textContent = "Idle";

    titleWrap.appendChild(title);
    titleWrap.appendChild(badge);

    const meta = document.createElement("div");
    meta.id = META_ID;
    meta.style.fontSize = "11px";
    meta.style.lineHeight = "1.5";
    meta.style.opacity = "0.78";
    meta.style.textAlign = "right";
    meta.style.whiteSpace = "pre-line";
    meta.textContent = "run policy.probe.run\n0 events · last activity —\nlast kind —";

    top.appendChild(titleWrap);
    top.appendChild(meta);

    const steps = document.createElement("div");
    steps.id = STEPS_ID;
    steps.style.display = "flex";
    steps.style.flexWrap = "wrap";
    steps.style.gap = "8px";
    steps.style.marginTop = "10px";

    card.appendChild(top);
    card.appendChild(steps);
    panel.insertBefore(card, feed);

    return card;
  }

  function render() {
    const card = ensureCard();
    const badge = document.getElementById(STATE_ID);
    const meta = document.getElementById(META_ID);
    const steps = document.getElementById(STEPS_ID);
    if (!card || !badge || !meta || !steps) return;

    const visual = getVisual(state.status);

    card.style.borderColor = visual.border;
    card.style.background = visual.background;

    badge.textContent = visual.label;
    badge.style.background = visual.badge;
    badge.style.border = `1px solid ${visual.border}`;
    badge.style.color = "rgba(255,255,255,0.95)";

    meta.textContent =
      `run ${state.runId}\n` +
      `${state.eventCount} events · last activity ${fmtFull(state.lastTs)}\n` +
      `last kind ${state.lastKind || "—"}`;

    const chips = [
      { label: "Started", done: state.started, active: state.status === "started" },
      { label: "Running", done: state.running, active: state.status === "running" },
      {
        label: state.failed ? "Failed" : "Completed",
        done: state.completed || state.failed,
        active: state.status === "completed" || state.status === "failed",
      },
    ];

    steps.innerHTML = "";

    for (const chip of chips) {
      const el = document.createElement("div");
      el.style.display = "inline-flex";
      el.style.alignItems = "center";
      el.style.gap = "6px";
      el.style.padding = "6px 10px";
      el.style.borderRadius = "999px";
      el.style.fontSize = "11px";
      el.style.fontWeight = "600";
      el.style.letterSpacing = "0.02em";
      el.style.border = "1px solid rgba(148,163,184,0.22)";
      el.style.background = "rgba(255,255,255,0.03)";
      el.style.opacity = chip.done || chip.active ? "1" : "0.72";

      if (chip.active) {
        el.style.borderColor = visual.border;
        el.style.background = visual.badge;
      } else if (chip.done) {
        el.style.borderColor = "rgba(148,163,184,0.30)";
        el.style.background = "rgba(255,255,255,0.06)";
      }

      const dot = document.createElement("span");
      dot.style.display = "inline-block";
      dot.style.width = "8px";
      dot.style.height = "8px";
      dot.style.borderRadius = "999px";
      dot.style.background = chip.done || chip.active
        ? "rgba(255,255,255,0.92)"
        : "rgba(148,163,184,0.68)";

      const text = document.createElement("span");
      text.textContent = chip.label;

      el.appendChild(dot);
      el.appendChild(text);
      steps.appendChild(el);
    }
  }

  function updateFromProbeEvent(detail) {
    const runId = String(detail?.run_id ?? detail?.runId ?? "");
    const kind = String(detail?.kind ?? "");
    const isProbe = runId === PROBE_RUN_ID || kind.startsWith("policy.probe");
    if (!isProbe) return;

    state.runId = runId || PROBE_RUN_ID;
    state.eventCount += 1;
    state.lastTs = typeof detail?.ts === "number" ? detail.ts : Date.now();
    state.lastKind = kind || "event";
    state.status = inferStatusFromKind(kind, state.status);

    if (state.status === "started") {
      state.started = true;
    } else if (state.status === "running") {
      state.started = true;
      state.running = true;
    } else if (state.status === "completed") {
      state.started = true;
      state.running = true;
      state.completed = true;
      state.failed = false;
    } else if (state.status === "failed") {
      state.started = true;
      state.running = true;
      state.failed = true;
      state.completed = false;
    }

    render();
  }

  async function hydrateFromRuns() {
    try {
      const res = await fetch(RUNS_API, { credentials: "same-origin" });
      if (!res.ok) return;
      const data = await res.json();
      const rows = Array.isArray(data?.rows) ? data.rows : [];
      const probeRow = rows.find((row) => String(row?.run_id || "") === PROBE_RUN_ID);
      if (!probeRow) {
        render();
        return;
      }

      state.runId = String(probeRow.run_id || PROBE_RUN_ID);
      state.lastTs = Number(probeRow.last_event_ts || Date.now());
      state.lastKind = String(probeRow.last_event_kind || "—");
      state.status = inferStatusFromKind(state.lastKind, state.status);

      if (state.status === "started") {
        state.started = true;
      } else if (state.status === "running") {
        state.started = true;
        state.running = true;
      } else if (state.status === "completed") {
        state.started = true;
        state.running = true;
        state.completed = true;
      } else if (state.status === "failed") {
        state.started = true;
        state.running = true;
        state.failed = true;
      }

      render();
    } catch (_) {
      render();
    }
  }

  function boot() {
    render();
    hydrateFromRuns();
    window.addEventListener("mb.task.event", (event) => updateFromProbeEvent(event.detail));

    const observer = new MutationObserver(() => {
      if (document.getElementById(PANEL_ID) && !document.getElementById(CARD_ID)) {
        render();
      }
    });

    observer.observe(document.documentElement, { childList: true, subtree: true });

    setInterval(() => {
      if (document.getElementById(PANEL_ID)) {
        render();
      }
    }, 3000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
