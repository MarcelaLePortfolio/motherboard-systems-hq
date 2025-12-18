/**
 * Phase 13.5 — Operator UX Overlay (dashboard-only; no backend/DB changes)
 *
 * Adds operator affordances:
 * - Fixed operator bar (API cue, focus buttons, reload)
 * - Toasts for API errors + uncaught errors
 * - Keyboard shortcuts: / (chat), t (task), r (reload), Esc (toggle bar)
 * - DOM wiring indicators (CHAT/TASK present)
 *
 * Best-effort only: must never break the dashboard.
 */
(() => {
  "use strict";

  const CFG = {
    storageKey: "__mbhq_opux_enabled",
    selectors: {
      // Chat
      chatInput: 'textarea[name="message"], textarea#message, textarea[data-role="matilda-input"], .matilda-chat textarea, #matilda-chat textarea, textarea',
      chatSendBtn: 'button[type="submit"], button[data-action="send"], .matilda-chat button',
      // Task delegation
      taskInput: 'input[name="task"], input#task, textarea[name="task"], #task, .task-panel input, .task-panel textarea',
      taskSendBtn: 'button[data-action="delegate"], .task-panel button, button',
    },
    apiPathsToProbe: [
      "/api/tasks",
      "/api/delegate-task",
      "/api/complete-task",
      "/api/matilda",
      "/api/chat",
    ],
    toastMs: 2400,
  };

  const STATE = {
    enabled: true,
    lastApiOkAt: null,
    lastApiErrAt: null,
    bar: null,
    toastHost: null,
  };

  function $(sel) {
    try { return document.querySelector(sel); } catch { return null; }
  }
  function $all(sel) {
    try { return Array.from(document.querySelectorAll(sel)); } catch { return []; }
  }

  function safeText(el, txt) {
    try { if (el) el.textContent = txt; } catch {}
  }

  function now() { return Date.now(); }

  function ensureToastHost() {
    if (STATE.toastHost) return STATE.toastHost;
    const host = document.createElement("div");
    host.className = "opux-toast-host";
    document.body.appendChild(host);
    STATE.toastHost = host;
    return host;
  }

  function toast(msg, kind = "ok") {
    if (!STATE.enabled) return;
    try {
      const host = ensureToastHost();
      const el = document.createElement("div");
      el.className = `opux-toast opux-${kind}`;
      el.textContent = msg;
      host.appendChild(el);
      setTimeout(() => {
        try { el.remove(); } catch {}
      }, CFG.toastMs);
    } catch {}
  }

  function focusFirst(sel, label) {
    const el = $(sel);
    if (el) {
      try { el.focus(); } catch {}
      toast(`${label}: focus`, "ok");
      return true;
    }
    toast(`${label}: not found`, "warn");
    return false;
  }

  function anyMatch(selectors) {
    for (const s of selectors) {
      const el = $(s);
      if (el) return el;
    }
    return null;
  }

  function detectWiring() {
    const chatEl = anyMatch([CFG.selectors.chatInput]);
    const taskEl = anyMatch([CFG.selectors.taskInput]);

    const chatBadge = $("#opux-chat");
    const taskBadge = $("#opux-task");

    safeText(chatBadge, chatEl ? "CHAT: OK" : "CHAT: MISS");
    safeText(taskBadge, taskEl ? "TASK: OK" : "TASK: MISS");

    if (chatBadge) chatBadge.classList.toggle("opux-bad", !chatEl);
    if (taskBadge) taskBadge.classList.toggle("opux-bad", !taskEl);

    return { chatOk: !!chatEl, taskOk: !!taskEl };
  }

  function ensureBar() {
    if (STATE.bar) return STATE.bar;

    const bar = document.createElement("div");
    bar.className = "opux-bar";
    bar.innerHTML = `
      <div class="opux-left">
        <span class="opux-badge">OPERATOR</span>
        <span class="opux-chip" id="opux-api">API: …</span>
        <span class="opux-chip" id="opux-chat">CHAT: …</span>
        <span class="opux-chip" id="opux-task">TASK: …</span>
      </div>
      <div class="opux-right">
        <button type="button" id="opux-btn-chat" title="/ = focus chat">Chat</button>
        <button type="button" id="opux-btn-task" title="t = focus task">Task</button>
        <button type="button" id="opux-btn-reload" title="r = reload">Reload</button>
        <button type="button" id="opux-btn-hide" title="Esc = toggle bar">Hide</button>
      </div>
    `;
    document.body.appendChild(bar);
    STATE.bar = bar;

    // Buttons
    const bChat = $("#opux-btn-chat");
    const bTask = $("#opux-btn-task");
    const bReload = $("#opux-btn-reload");
    const bHide = $("#opux-btn-hide");

    if (bChat) bChat.addEventListener("click", () => focusFirst(CFG.selectors.chatInput, "Chat"));
    if (bTask) bTask.addEventListener("click", () => focusFirst(CFG.selectors.taskInput, "Task"));
    if (bReload) bReload.addEventListener("click", () => location.reload());
    if (bHide) bHide.addEventListener("click", () => toggleEnabled());

    return bar;
  }

  function setEnabled(on) {
    STATE.enabled = !!on;
    try { localStorage.setItem(CFG.storageKey, JSON.stringify(STATE.enabled)); } catch {}
    if (STATE.bar) STATE.bar.style.display = STATE.enabled ? "" : "none";
    if (STATE.enabled) toast("Operator UX enabled", "ok");
  }

  function toggleEnabled() {
    setEnabled(!STATE.enabled);
  }

  function installShortcuts() {
    document.addEventListener("keydown", (e) => {
      // Don't hijack typing
      const tag = (e.target && e.target.tagName) ? e.target.tagName.toUpperCase() : "";
      if (["INPUT", "TEXTAREA"].includes(tag)) return;

      if (e.key === "Escape") {
        e.preventDefault();
        toggleEnabled();
        return;
      }
      if (!STATE.enabled) return;

      if (e.key === "/") {
        e.preventDefault();
        focusFirst(CFG.selectors.chatInput, "Chat");
      }
      if (e.key === "t") {
        e.preventDefault();
        focusFirst(CFG.selectors.taskInput, "Task");
      }
      if (e.key === "r") {
        e.preventDefault();
        location.reload();
      }
    });
  }

  function installGlobalErrorToasts() {
    window.addEventListener("error", (ev) => {
      try {
        const msg = (ev && ev.message) ? String(ev.message) : "Runtime error";
        toast(msg.slice(0, 120), "err");
      } catch {}
    });
    window.addEventListener("unhandledrejection", (ev) => {
      try {
        const msg = (ev && ev.reason) ? String(ev.reason) : "Unhandled rejection";
        toast(msg.slice(0, 120), "err");
      } catch {}
    });
  }

  function installFetchTap() {
    if (window.__mbhq_opux_fetch_tap_installed) return;
    window.__mbhq_opux_fetch_tap_installed = true;

    const nativeFetch = window.fetch ? window.fetch.bind(window) : null;
    if (!nativeFetch) return;

    window.fetch = async (...args) => {
      try {
        const res = await nativeFetch(...args);
        try {
          const url = String(args[0] ?? "");
          if (url.includes("/api/")) {
            const apiEl = $("#opux-api");
            if (res && res.ok) {
              STATE.lastApiOkAt = now();
              if (apiEl) apiEl.textContent = "API: OK";
              if (apiEl) apiEl.classList.remove("opux-bad");
            } else {
              STATE.lastApiErrAt = now();
              if (apiEl) apiEl.textContent = "API: ERR";
              if (apiEl) apiEl.classList.add("opux-bad");
              toast("API error", "warn");
            }
          }
        } catch {}
        return res;
      } catch (e) {
        const apiEl = $("#opux-api");
        if (apiEl) apiEl.textContent = "API: ERR";
        if (apiEl) apiEl.classList.add("opux-bad");
        toast("API network error", "err");
        throw e;
      }
    };
  }

  async function probeApiOnce() {
    const apiEl = $("#opux-api");
    if (!apiEl) return;

    // light-touch: try a few endpoints until one responds
    for (const p of CFG.apiPathsToProbe) {
      try {
        const r = await fetch(p, { method: "GET", cache: "no-store" });
        if (r && r.ok) {
          STATE.lastApiOkAt = now();
          apiEl.textContent = "API: OK";
          apiEl.classList.remove("opux-bad");
          return;
        }
      } catch {}
    }

    STATE.lastApiErrAt = now();
    apiEl.textContent = "API: ?";
    apiEl.classList.add("opux-bad");
  }

  function boot() {
    try {
      STATE.enabled = JSON.parse(localStorage.getItem(CFG.storageKey) ?? "true");
    } catch {
      STATE.enabled = true;
    }

    ensureBar();
    installFetchTap();
    installShortcuts();
    installGlobalErrorToasts();

    // Wiring indicators
    detectWiring();
    setInterval(detectWiring, 1500);

    // API indicator
    probeApiOnce();
    setInterval(probeApiOnce, 12000);

    if (STATE.bar) STATE.bar.style.display = STATE.enabled ? "" : "none";
    toast("Operator UX ready", "ok");
  }

  document.readyState === "loading"
    ? document.addEventListener("DOMContentLoaded", boot)
    : boot();
})();
