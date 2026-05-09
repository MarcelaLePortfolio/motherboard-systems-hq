
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

helper_anchor = "  async function phase717RetryTask(taskId, mode, button) {"

helper = r'''  function phase717EscapeModalText(value) {

    return String(value ?? "")

      .replace(/&/g, "&amp;")

      .replace(/</g, "&lt;")

      .replace(/>/g, "&gt;")

      .replace(/"/g, "&quot;")

      .replace(/'/g, "&#39;");

  }

  function phase717RetryModal(options) {

    return new Promise((resolve) => {

      const rootId = "phase717-retry-modal-root";

      let root = document.getElementById(rootId);

      if (!root) {

        root = document.createElement("div");

        root.id = rootId;

        document.body.appendChild(root);

      }

      const title = phase717EscapeModalText(options.title || "Confirm action");

      const message = phase717EscapeModalText(options.message || "");

      const confirmLabel = phase717EscapeModalText(options.confirmLabel || "Confirm");

      const cancelLabel = options.cancelLabel === null ? null : phase717EscapeModalText(options.cancelLabel || "Cancel");

      const tone = options.tone === "error" ? "#fecaca" : options.tone === "success" ? "#bbf7d0" : "#dbeafe";

      const border = options.tone === "error" ? "rgba(248,113,113,.45)" : options.tone === "success" ? "rgba(74,222,128,.42)" : "rgba(96,165,250,.45)";

      root.innerHTML = `

        <div data-phase717-modal-overlay="true" style="position:fixed;inset:0;z-index:9999;display:flex;align-items:center;justify-content:center;padding:18px;background:rgba(2,6,23,.72);backdrop-filter:blur(6px);">

          <section role="dialog" aria-modal="true" aria-labelledby="phase717-retry-modal-title" style="width:min(520px,calc(100vw - 28px));border:1px solid ${border};border-radius:16px;background:rgba(15,23,42,.98);box-shadow:0 24px 80px rgba(0,0,0,.45);padding:16px;color:#e5e7eb;">

            <div id="phase717-retry-modal-title" style="font-size:14px;font-weight:800;color:${tone};letter-spacing:.01em;">${title}</div>

            <div style="margin-top:8px;color:#cbd5e1;font-size:12px;line-height:1.5;white-space:pre-wrap;overflow-wrap:anywhere;">${message}</div>

            <div style="display:flex;justify-content:flex-end;gap:8px;margin-top:14px;">

              ${cancelLabel ? `<button type="button" data-phase717-modal-cancel="true" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.85);color:#cbd5e1;border-radius:10px;padding:7px 10px;font-size:12px;">${cancelLabel}</button>` : ""}

              <button type="button" data-phase717-modal-confirm="true" style="cursor:pointer;border:1px solid ${border};background:rgba(30,41,59,.95);color:${tone};border-radius:10px;padding:7px 10px;font-size:12px;font-weight:700;">${confirmLabel}</button>

            </div>

          </section>

        </div>

      `;

      const close = (value) => {

        root.innerHTML = "";

        resolve(value);

      };

      const confirm = root.querySelector("[data-phase717-modal-confirm]");

      const cancel = root.querySelector("[data-phase717-modal-cancel]");

      const overlay = root.querySelector("[data-phase717-modal-overlay]");

      if (confirm) confirm.focus();

      if (confirm) confirm.addEventListener("click", () => close(true), { once: true });

      if (cancel) cancel.addEventListener("click", () => close(false), { once: true });

      if (overlay) {

        overlay.addEventListener("click", (event) => {

          if (event.target === overlay) close(false);

        }, { once: true });

      }

    });

  }

'''

if helper_anchor not in text:

    raise SystemExit("RETRY FUNCTION ANCHOR NOT FOUND")

if "function phase717RetryModal(options)" not in text:

    text = text.replace(helper_anchor, helper + helper_anchor, 1)

replacements = {

    'alert("Missing task id; retry was not submitted.");': 'await phase717RetryModal({ title: "Retry not submitted", message: "Missing task id; retry was not submitted.", confirmLabel: "Close", cancelLabel: null, tone: "error" });',

    'const ok = window.confirm(`Submit ${label} for task ${taskId}?`);': 'const ok = await phase717RetryModal({ title: "Confirm retry action", message: `Submit ${label} for task ${taskId}?\\n\\nThis uses the verified /api/delegate-task retry contract and requires explicit operator confirmation.`, confirmLabel: "Submit", cancelLabel: "Cancel" });',

    'alert(`Retry submitted: ${data.task_id || data.id || "created"}`);': 'await phase717RetryModal({ title: "Retry submitted", message: `Retry submitted: ${data.task_id || data.id || "created"}`, confirmLabel: "Close", cancelLabel: null, tone: "success" });',

    'alert(`Retry failed: ${err && err.message ? err.message : String(err)}`);': 'await phase717RetryModal({ title: "Retry failed", message: `${err && err.message ? err.message : String(err)}`, confirmLabel: "Close", cancelLabel: null, tone: "error" });',

}

for old, new in replacements.items():

    if old not in text:

        raise SystemExit(f"EXPECTED STRING NOT FOUND: {old}")

    text = text.replace(old, new, 1)

path.write_text(text)

print("Phase 717 retry modal patch applied.")

