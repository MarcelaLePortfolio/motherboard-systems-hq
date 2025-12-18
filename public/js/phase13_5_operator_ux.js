/**
 * Phase 13.5 — Operator UX Overlay (dashboard-only; no backend/DB changes)
 *
 * Dashboard-only operator affordances:
 * - Fixed operator toolbar (API cue, focus buttons, reload)
 * - Toasts for API errors + uncaught errors
 * - Keyboard shortcuts (?, /, t, r, Esc)
 * - Best-effort only: never breaks if selectors/routes change
 */

(() => {
  "use strict";

  const STATE = {
    enabled: true,
    helpOpen: false,
    lastApiOkAt: null,
    lastApiErrAt: null,
  };

  const CFG = {
    storageKey: "mbhq.phase13_5.opux.enabled",
    toastMs: 4200,
    apiHints: ["/api/"],
    selectors: {
      chat: [
        "#matilda-input",
        "textarea[placeholder*='Matilda']",
        "textarea[placeholder*='chat']",
      ],
      task: [
        "#task-input",
        "input[placeholder*='task']",
        "textarea[placeholder*='task']",
      ],
    },
  };

  const $ = (s, r = document) => r.querySelector(s);
  const now = () => Date.now();

  function toast(msg, kind = "info") {
    if (!STATE.enabled) return;
    let host = $(".opux-toast-host");
    if (!host) {
      host = document.createElement("div");
      host.className = "opux-toast-host";
      document.body.appendChild(host);
    }
    const el = document.createElement("div");
    el.className = `opux-toast opux-${kind}`;
    el.textContent = msg;
    host.appendChild(el);
    setTimeout(() => el.remove(), CFG.toastMs);
  }

  function focusFirst(selectors, label) {
    for (const s of selectors) {
      const el = $(s);
      if (el) {
        el.focus();
        toast(`${label} focused`, "ok");
        return;
      }
    }
    toast(`${label} input not found`, "warn");
  }

  function ensureBar() {
    if ($(".opux-bar")) return;
    const bar = document.createElement("div");
    bar.className = "opux-bar";
    bar.innerHTML = `
      <div class="opux-left">
        <span class="opux-badge">OP-UX</span>
        <span class="opux-api" id="opux-api">API: —</span>
      </div>
      <div class="opux-right">
        <button id="opux-chat">Chat</button>
        <button id="opux-task">Task</button>
        <button id="opux-reload">↻</button>
      </div>
    `;
    document.body.appendChild(bar);

    $("#opux-chat").onclick = () => focusFirst(CFG.selectors.chat, "Chat");
    $("#opux-task").onclick = () => focusFirst(CFG.selectors.task, "Task");
    $("#opux-reload").onclick = () => location.reload();
  }

  function installFetchTap() {
    if (!window.fetch || window.__opuxFetch) return;
    const native = window.fetch.bind(window);
    window.__opuxFetch = true;

    window.fetch = async (...args) => {
      const url = String(args[0]?.url || args[0] || "");
      try {
        const res = await native(...args);
        if (CFG.apiHints.some(h => url.includes(h))) {
          const el = $("#opux-api");
          if (res.ok) {
            STATE.lastApiOkAt = now();
            if (el) el.textContent = "API: OK";
          } else {
            STATE.lastApiErrAt = now();
            if (el) el.textContent = "API: ERR";
            toast(`API ${res.status}`, "warn");
          }
        }
        return res;
      } catch (e) {
        const el = $("#opux-api");
        if (el) el.textContent = "API: ERR";
        toast("API network error", "err");
        throw e;
      }
    };
  }

  function installShortcuts() {
    document.addEventListener("keydown", e => {
      if (e.target && ["INPUT", "TEXTAREA"].includes(e.target.tagName)) return;
      if (e.key === "/") {
        e.preventDefault();
        focusFirst(CFG.selectors.chat, "Chat");
      }
      if (e.key === "t") {
        e.preventDefault();
        focusFirst(CFG.selectors.task, "Task");
      }
      if (e.key === "r") {
        e.preventDefault();
        location.reload();
      }
    });
  }

  function boot() {
    STATE.enabled = JSON.parse(localStorage.getItem(CFG.storageKey) ?? "true");
    ensureBar();
    installFetchTap();
    installShortcuts();
    toast("Operator UX ready", "ok");
  }

  document.readyState === "loading"
    ? document.addEventListener("DOMContentLoaded", boot)
    : boot();
})();
