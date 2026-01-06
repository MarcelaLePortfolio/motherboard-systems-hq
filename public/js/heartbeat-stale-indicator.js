/**
 * Phase 16 – Heartbeat stale-state indicator (non-intrusive)
 *
 * Reads window.__HB (from sse-heartbeat-shim) and updates a tiny badge.
 * - Adds a badge to the top-right corner of the dashboard.
 * - Shows OK when both OPS+Tasks have recent heartbeats.
 * - Shows STALE when either stream is missing or old.
 *
 * No coupling to widget internals. Safe to remove.
 */
(function () {
  const w = window;
  const HB = w.__HB;

  function now() {
    return Date.now();
  }

  function ms(n) {
    return Math.max(0, Number(n) || 0);
  }

  // Consider heartbeats stale after this many ms.
  const STALE_MS = 15000;

  function fmtAge(ts) {
    if (!ts) return "—";
    const s = Math.floor((now() - ts) / 1000);
    return s <= 0 ? "0s" : `${s}s`;
  }

  function ensureBadge() {
    let el = document.getElementById("hb-badge");
    if (el) return el;

    el = document.createElement("div");
    el.id = "hb-badge";
    el.setAttribute("role", "status");
    el.style.position = "fixed";
    el.style.top = "12px";
    el.style.right = "12px";
    el.style.zIndex = "9999";
    el.style.fontFamily = "ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial";
    el.style.fontSize = "12px";
    el.style.padding = "6px 10px";
    el.style.borderRadius = "999px";
    el.style.border = "1px solid rgba(255,255,255,0.14)";
    el.style.background = "rgba(0,0,0,0.55)";
    el.style.backdropFilter = "blur(6px)";
    el.style.webkitBackdropFilter = "blur(6px)";
    el.style.color = "rgba(255,255,255,0.92)";
    el.style.boxShadow = "0 8px 18px rgba(0,0,0,0.35)";
    el.style.userSelect = "none";
    el.style.cursor = "default";
    document.body.appendChild(el);
    return el;
  }

  function setState(el, ok) {
    // No colors specified by instruction in other contexts; keep neutral text-only signal.
    // We’ll use symbols instead of colored fills.
    el.textContent = ok
      ? `HB ✓ (ops ${fmtAge(HB && HB.get("ops"))}, tasks ${fmtAge(HB && HB.get("tasks"))})`
      : `HB ! (ops ${fmtAge(HB && HB.get("ops"))}, tasks ${fmtAge(HB && HB.get("tasks"))})`;
  }

  function tick() {
    const el = ensureBadge();

    if (!HB || typeof HB.get !== "function") {
      el.textContent = "HB ? (shim not loaded)";
      return;
    }

    const ops = HB.get("ops");
    const tasks = HB.get("tasks");

    const opsOk = !!ops && ms(now() - ops) <= STALE_MS;
    const tasksOk = !!tasks && ms(now() - tasks) <= STALE_MS;

    setState(el, opsOk && tasksOk);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => {
      tick();
      setInterval(tick, 1000);
    });
  } else {
    tick();
    setInterval(tick, 1000);
  }
})();
