
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

python3 << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old_details = '${explanation ? `<div data-phase717-compact-details="true" style="margin-top:8px;color:#93c5fd;font-size:12px;overflow-wrap:anywhere;">Details available in the read-only audit/evidence surfaces.</div>` : ""}'

new_details = '${explanation ? `<button type="button" data-phase717-inspect-details="true" data-phase717-inspect-title="${title} — Details" data-phase717-inspect-content="${explanation}" style="margin-top:8px;cursor:pointer;border:1px solid rgba(147,197,253,.35);background:rgba(30,64,175,.14);color:#93c5fd;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect details</button>` : ""}'

old_trace = '${traceJson ? `<div data-phase717-compact-advanced-trace="true" style="margin-top:6px;color:#fbbf24;font-size:12px;overflow-wrap:anywhere;">Advanced trace captured; use /execution-evidence.html for read-only forensic review.</div>` : ""}'

new_trace = '${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:6px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 8px;font-size:11px;">Inspect trace</button>` : ""}'

if old_details not in text:

    raise SystemExit("Expected compact details notice not found; refusing speculative patch.")

if old_trace not in text:

    raise SystemExit("Expected compact advanced trace notice not found; refusing speculative patch.")

text = text.replace(old_details, new_details, 1)

text = text.replace(old_trace, new_trace, 1)

modal_anchor = "  function phase717RetryModal(options) {"

modal_fn = r'''

  function phase717InspectionModal(options) {

    return new Promise((resolve) => {

      const rootId = "phase717-inspection-modal-root";

      let root = document.getElementById(rootId);

      if (!root) {

        root = document.createElement("div");

        root.id = rootId;

        document.body.appendChild(root);

      }

      const title = String(options.title || "Read-only inspection");

      const content = String(options.content || "No inspection content available.");

      root.innerHTML = `

        <div data-phase717-inspection-overlay="true" style="position:fixed;inset:0;z-index:9998;display:flex;align-items:center;justify-content:center;padding:18px;background:rgba(2,6,23,.72);backdrop-filter:blur(6px);">

          <section role="dialog" aria-modal="true" aria-labelledby="phase717-inspection-modal-title" style="width:min(760px,calc(100vw - 28px));max-height:min(760px,calc(100vh - 36px));display:flex;flex-direction:column;border:1px solid rgba(148,163,184,.36);border-radius:16px;background:rgba(15,23,42,.98);box-shadow:0 24px 80px rgba(0,0,0,.45);padding:16px;color:#e5e7eb;">

            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:10px;">

              <div>

                <div id="phase717-inspection-modal-title" style="font-size:14px;font-weight:800;color:#dbeafe;letter-spacing:.01em;"></div>

                <div style="margin-top:4px;color:#94a3b8;font-size:11px;">Read-only inspection. No execution, retry, or mutation is triggered from this view.</div>

              </div>

              <button type="button" data-phase717-inspection-close="true" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.85);color:#cbd5e1;border-radius:10px;padding:6px 9px;font-size:12px;">Close</button>

            </div>

            <pre data-phase717-inspection-content="true" style="display:block;box-sizing:border-box;width:100%;max-width:100%;min-height:140px;max-height:560px;overflow:auto;margin-top:12px;padding:10px;border-radius:10px;border:1px solid rgba(51,65,85,.7);background:#020617;color:#e5e7eb;font-size:11px;line-height:1.45;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;"></pre>

          </section>

        </div>

      `;

      const titleNode = root.querySelector("#phase717-inspection-modal-title");

      const contentNode = root.querySelector("[data-phase717-inspection-content]");

      const closeButton = root.querySelector("[data-phase717-inspection-close]");

      const overlay = root.querySelector("[data-phase717-inspection-overlay]");

      if (titleNode) titleNode.textContent = title;

      if (contentNode) contentNode.textContent = content;

      const close = () => {

        root.innerHTML = "";

        resolve(true);

      };

      if (closeButton) closeButton.focus();

      if (closeButton) closeButton.addEventListener("click", close, { once: true });

      if (overlay) {

        overlay.addEventListener("click", (event) => {

          if (event.target === overlay) close();

        });

      }

    });

  }

'''

if "function phase717InspectionModal" in text:

    raise SystemExit("Inspection modal already present; refusing duplicate insertion.")

if modal_anchor not in text:

    raise SystemExit("Retry modal anchor not found; refusing speculative patch.")

text = text.replace(modal_anchor, modal_fn + "\n" + modal_anchor, 1)

listener_anchor = '''  document.addEventListener("click", function(event) {

    const requeue = event.target.closest("[data-phase717-requeue]");

'''

inspection_listener = '''  document.addEventListener("click", function(event) {

    const detailButton = event.target.closest("[data-phase717-inspect-details]");

    const traceButton = event.target.closest("[data-phase717-inspect-trace]");

    const inspectionButton = detailButton || traceButton;

    if (!inspectionButton) return;

    event.preventDefault();

    phase717InspectionModal({

      title: inspectionButton.getAttribute("data-phase717-inspect-title") || "Read-only inspection",

      content: inspectionButton.getAttribute("data-phase717-inspect-content") || "No inspection content available."

    });

  });

'''

if listener_anchor not in text:

    raise SystemExit("Confirmed click listener anchor not found; refusing patch.")

if "data-phase717-inspect-details" not in text or "data-phase717-inspect-trace" not in text:

    raise SystemExit("Inspection chip markers missing after replacement; refusing listener insertion.")

text = text.replace(listener_anchor, inspection_listener + listener_anchor, 1)

path.write_text(text)

PY

cat > PHASE717_READONLY_INSPECTION_MODAL.md << 'NOTE'

# Phase 717 Read-Only Inspection Modal

Implemented after external backup source-b25e7532.tar.gz and anchor discovery at 50be4cce.

Changed file:

- public/js/phase530_visible_panels_bridge.js

Behavior:

- Replaces passive compact evidence notices with clickable chips.

- "Inspect details" opens a read-only modal with task explanation content.

- "Inspect trace" opens a read-only modal with advanced trace content.

- Modal explicitly states it does not trigger execution, retry, or mutation.

- Requeue and Retry differently controls remain unchanged.

- /execution-evidence.html remains the heavyweight secondary audit surface.

Boundary:

- no broad CSS changes

- no DB changes

- no API contract changes

- no chat coupling

- no execution coupling

NOTE

docker compose restart dashboard

sleep 3

curl -fsS http://localhost:3000 >/tmp/phase717_readonly_inspection_modal.html

wc -c /tmp/phase717_readonly_inspection_modal.html

grep -nE "data-phase717-inspect-details|data-phase717-inspect-trace|phase717InspectionModal|phase717-inspection-modal-root" public/js/phase530_visible_panels_bridge.js

grep -nE "data-phase717-requeue|data-phase717-retry-differently|phase717RetryTask" public/js/phase530_visible_panels_bridge.js

docker compose ps

git status --short

git add public/js/phase530_visible_panels_bridge.js PHASE717_ADD_READONLY_INSPECTION_MODAL.sh PHASE717_READONLY_INSPECTION_MODAL.md

git commit -m "Phase 717: add read-only inspection modal chips"

git push origin dev

