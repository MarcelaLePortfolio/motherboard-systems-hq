#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET_HTML="public/dashboard.html"
TARGET_JS="public/js/dashboard-delegation.js"

scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"

cp "$TARGET_HTML" "${TARGET_HTML}.bak.phase61_5_3"
cp "$TARGET_JS" "${TARGET_JS}.bak.phase61_5_3"

python3 - << 'PY'
from pathlib import Path

html_path = Path("public/dashboard.html")
html = html_path.read_text()

old = '<div id="delegation-response" class="mt-2 text-sm text-gray-300 italic"></div>'
new = '''<div id="delegation-status-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
                      <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Delegation Status</div>
                      <div id="delegation-response" class="text-sm text-gray-300 leading-6">
                        Awaiting operator input.<br>
                        Results from delegation requests will appear here.
                      </div>
                    </div>'''

if old not in html:
    raise SystemExit("delegation response anchor not found in public/dashboard.html")

html = html.replace(old, new, 1)
html_path.write_text(html)
PY

cat > "$TARGET_JS" << 'JS'
(function () {
  console.log("[dashboard-delegation] module loaded");

  function $(id) {
    return document.getElementById(id);
  }

  function getSafeFetch() {
    var f = window.fetch;
    var t = typeof f;
    console.log("[dashboard-delegation] detected fetch type:", t);
    if (t !== "function") {
      console.error("[dashboard-delegation] fetch is not a function; value:", f);
      return null;
    }
    return f.bind(window);
  }

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function formatJsonBlock(obj) {
    return "<pre class=\"mt-3 overflow-x-auto whitespace-pre-wrap break-words rounded-lg bg-black/20 p-3 text-xs text-gray-300\">" +
      escapeHtml(JSON.stringify(obj, null, 2)) +
      "</pre>";
  }

  function setResponseState(kind, html) {
    var response = $("delegation-response");
    var panel = $("delegation-status-panel");
    if (!response) return;

    response.innerHTML = html;

    if (!panel) return;
    panel.classList.remove("border-gray-700", "border-teal-600", "border-green-600", "border-red-600", "border-amber-500");

    if (kind === "sending") panel.classList.add("border-teal-600");
    else if (kind === "success") panel.classList.add("border-green-600");
    else if (kind === "error") panel.classList.add("border-red-600");
    else if (kind === "waiting") panel.classList.add("border-amber-500");
    else panel.classList.add("border-gray-700");
  }

  function setIdle() {
    setResponseState(
      "idle",
      "Awaiting operator input.<br>Results from delegation requests will appear here."
    );
  }

  function setSending(text) {
    setResponseState(
      "sending",
      "<div class=\"text-teal-300 font-medium\">Sending delegation…</div>" +
      "<div class=\"mt-2 text-gray-400\">Preparing request for the orchestration layer.</div>" +
      (text ? "<div class=\"mt-3 rounded-lg bg-black/20 p-3 text-xs text-gray-300 break-words\">" + escapeHtml(text) + "</div>" : "")
    );
  }

  function setWaiting() {
    setResponseState(
      "waiting",
      "<div class=\"text-amber-300 font-medium\">Still waiting on delegation response…</div>" +
      "<div class=\"mt-2 text-gray-400\">The request may still be processing.</div>"
    );
  }

  function setSuccess(data) {
    var summary = "Delegation accepted.";
    if (data && typeof data === "object") {
      summary =
        data.message ||
        data.status ||
        data.result ||
        data.reply ||
        data.ok && "Delegation accepted." ||
        summary;
    }

    setResponseState(
      "success",
      "<div class=\"text-green-300 font-medium\">" + escapeHtml(summary) + "</div>" +
      "<div class=\"mt-2 text-gray-400\">Request completed successfully.</div>" +
      (data && typeof data === "object" ? formatJsonBlock(data) : "")
    );
  }

  function setError(message, extra) {
    setResponseState(
      "error",
      "<div class=\"text-red-300 font-medium\">Delegation failed.</div>" +
      "<div class=\"mt-2 text-gray-300\">" + escapeHtml(message || "Unknown error") + "</div>" +
      (extra ? "<div class=\"mt-3 text-xs text-gray-400 break-words\">" + escapeHtml(extra) + "</div>" : "")
    );
  }

  async function onDelegationClick() {
    var input = $("delegation-input");
    var btn = $("delegation-submit");
    if (!input) {
      console.warn("[dashboard-delegation] delegation input not found at click time");
      setError("Delegation input field was not found.");
      return;
    }

    var value = String(input.value || "").trim();
    if (!value) {
      console.warn("[dashboard-delegation] empty delegation input; skipping");
      setError("Please enter a delegation request before submitting.");
      return;
    }

    console.log("[dashboard-delegation] sending delegation:", value);
    var safeFetch = getSafeFetch();
    if (!safeFetch) {
      console.error("[dashboard-delegation] aborting delegation because fetch is unavailable or invalid");
      setError("Browser fetch is unavailable.");
      return;
    }

    var oldText = btn ? (btn.textContent || "Submit Delegation") : "Submit Delegation";
    var waitingTimer = null;

    try {
      if (btn) {
        btn.disabled = true;
        btn.textContent = "Sending...";
        btn.classList.add("opacity-70", "cursor-not-allowed");
      }

      setSending(value);
      waitingTimer = window.setTimeout(setWaiting, 4000);

      var res;
      try {
        res = await safeFetch("/api/delegate-task", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
          body: JSON.stringify({ prompt: value, message: value, text: value, task: value })
        });
      } catch (err) {
        console.error("[dashboard-delegation] fetch threw before response:", err);
        throw err;
      }

      console.log("[dashboard-delegation] fetch returned:", {
        ok: res && res.ok,
        status: res && res.status,
        statusText: res && res.statusText
      });

      var data = null;
      var rawText = "";
      try {
        rawText = await res.text();
        data = rawText ? JSON.parse(rawText) : {};
      } catch (err) {
        console.error("[dashboard-delegation] error parsing JSON response:", err);
        data = { error: "Non-JSON response from /api/delegate-task", raw: rawText || "" };
      }

      console.log("[dashboard-delegation] delegation response:", data);

      if (!res.ok) {
        setError(
          (data && (data.error || data.message || data.statusText)) || ("HTTP " + res.status + " " + (res.statusText || "")),
          rawText
        );
        return;
      }

      setSuccess(data);
    } catch (err) {
      setError(err && err.message ? err.message : String(err));
    } finally {
      if (waitingTimer) window.clearTimeout(waitingTimer);
      if (btn) {
        btn.disabled = false;
        btn.textContent = oldText;
        btn.classList.remove("opacity-70", "cursor-not-allowed");
      }
    }
  }

  function init() {
    var btn = $("delegation-submit");
    var input = $("delegation-input");
    if (!btn || !input) {
      console.warn("[dashboard-delegation] delegation button or input not found in init");
      return;
    }

    setIdle();

    if (btn.dataset.delegationWired === "true") {
      console.log("[dashboard-delegation] Task Delegation wiring already active");
      return;
    }

    btn.dataset.delegationWired = "true";
    btn.addEventListener("click", onDelegationClick);

    input.addEventListener("keydown", function (e) {
      if ((e.metaKey || e.ctrlKey) && e.key === "Enter") {
        e.preventDefault();
        onDelegationClick();
      }
    });

    console.log("[dashboard-delegation] Task Delegation wiring active");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();
JS

scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"
npm run build:dashboard-bundle
