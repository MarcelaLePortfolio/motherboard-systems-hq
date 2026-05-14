
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: ADD PREVIEW MODAL FRONTEND ONLY ====="

mkdir -p checkpoints

TARGET="public/js/phase530_visible_panels_bridge.js"

BRANCH="$(git branch --show-current)"

cp "$TARGET" checkpoints/PHASE719_PHASE530_PRE_PREVIEW_MODAL.js

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

if "const artifactPath =" not in text:

    marker = '      const artifactSize = artifactRaw && artifactRaw.size_bytes ? esc(String(artifactRaw.size_bytes) + " bytes") : "";\n'

    insert = '      const artifactPath = artifactRaw ? esc(artifactRaw.path || "") : "";\n'

    if marker not in text:

        raise SystemExit("Could not locate artifactSize line.")

    text = text.replace(marker, marker + insert, 1)

old_button = 'data-phase719-preview-artifact="true" data-task-id="${taskId}" data-task-title="${title}" title="Preview completed artifact"'

new_button = 'data-phase719-preview-artifact="true" data-task-id="${taskId}" data-task-title="${title}" data-artifact-name="${artifactName}" data-artifact-type="${artifactType}" data-artifact-size="${artifactSize}" data-artifact-path="${artifactPath}" data-artifact-outcome="${outcome}" data-artifact-explanation="${explanation}" title="Preview completed artifact"'

if new_button not in text:

    if old_button not in text:

        raise SystemExit("Could not locate Preview button attributes.")

    text = text.replace(old_button, new_button, 1)

modal_code = r'''

  // Phase 719 — Preview artifact modal (frontend-only, read-only)

  function phase719EnsurePreviewModal() {

    let modal = document.getElementById("phase719-preview-modal");

    if (modal) return modal;

    modal = document.createElement("div");

    modal.id = "phase719-preview-modal";

    modal.style.cssText = "display:none;position:fixed;inset:0;z-index:9999;background:rgba(2,6,23,.72);backdrop-filter:blur(5px);align-items:center;justify-content:center;padding:18px;";

    modal.innerHTML = `

      <div role="dialog" aria-modal="true" aria-labelledby="phase719-preview-title" style="width:min(760px,96vw);max-height:86vh;overflow:auto;background:#020617;border:1px solid rgba(148,163,184,.35);border-radius:16px;box-shadow:0 24px 70px rgba(0,0,0,.55);padding:16px;color:#e5e7eb;">

        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:12px;">

          <div>

            <div id="phase719-preview-title" style="font-size:14px;font-weight:800;color:#f8fafc;">Artifact Preview</div>

            <div id="phase719-preview-subtitle" style="margin-top:4px;font-size:11px;color:#94a3b8;overflow-wrap:anywhere;"></div>

          </div>

          <button type="button" data-phase719-preview-close="true" style="cursor:pointer;border:1px solid rgba(148,163,184,.35);background:rgba(15,23,42,.85);color:#cbd5e1;border-radius:999px;padding:5px 10px;font-size:12px;">Close</button>

        </div>

        <div id="phase719-preview-meta" style="font-size:12px;line-height:1.6;color:#bbf7d0;border:1px solid rgba(134,239,172,.25);background:rgba(20,83,45,.12);border-radius:12px;padding:10px;margin-bottom:12px;"></div>

        <pre id="phase719-preview-body" style="white-space:pre-wrap;overflow-wrap:anywhere;font-size:12px;line-height:1.55;color:#dbeafe;border:1px solid rgba(96,165,250,.24);background:rgba(15,23,42,.65);border-radius:12px;padding:12px;margin:0;"></pre>

      </div>

    `;

    document.body.appendChild(modal);

    modal.addEventListener("click", function (event) {

      if (event.target === modal || event.target.closest("[data-phase719-preview-close]")) {

        modal.style.display = "none";

      }

    });

    document.addEventListener("keydown", function (event) {

      if (event.key === "Escape" && modal.style.display !== "none") {

        modal.style.display = "none";

      }

    });

    return modal;

  }

  function phase719OpenPreviewModal(button) {

    const modal = phase719EnsurePreviewModal();

    const title = modal.querySelector("#phase719-preview-title");

    const subtitle = modal.querySelector("#phase719-preview-subtitle");

    const meta = modal.querySelector("#phase719-preview-meta");

    const body = modal.querySelector("#phase719-preview-body");

    const taskTitle = button.getAttribute("data-task-title") || "Artifact Preview";

    const taskId = button.getAttribute("data-task-id") || "";

    const name = button.getAttribute("data-artifact-name") || "artifact";

    const type = button.getAttribute("data-artifact-type") || "artifact";

    const size = button.getAttribute("data-artifact-size") || "";

    const path = button.getAttribute("data-artifact-path") || "";

    const outcome = button.getAttribute("data-artifact-outcome") || "";

    const explanation = button.getAttribute("data-artifact-explanation") || "";

    title.textContent = "Preview: " + taskTitle;

    subtitle.textContent = taskId ? "task_id: " + taskId : "";

    meta.textContent = [

      "artifact: " + name,

      type ? "type: " + type : "",

      size ? "size: " + size : "",

      path ? "path: " + path : ""

    ].filter(Boolean).join("\n");

    body.textContent = [

      outcome ? "Outcome:\n" + outcome : "",

      explanation ? "Explanation:\n" + explanation : "",

      !outcome && !explanation ? "Artifact metadata is available. File content preview is not wired yet." : ""

    ].filter(Boolean).join("\n\n");

    modal.style.display = "flex";

  }

  document.addEventListener("click", function (event) {

    const button = event.target.closest("[data-phase719-preview-artifact]");

    if (!button) return;

    event.preventDefault();

    phase719OpenPreviewModal(button);

  });

'''

if "phase719EnsurePreviewModal" not in text:

    idx = text.rfind("\n})();")

    if idx == -1:

        raise SystemExit("Could not locate final IIFE close.")

    text = text[:idx] + "\n" + modal_code + text[idx:]

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" checkpoints/PHASE719_PHASE530_POST_PREVIEW_MODAL.js

docker compose up -d --build dashboard

sleep 5

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "STATIC JS MODAL MARKERS"

  curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -nE "phase719-preview-modal|phase719OpenPreviewModal|data-artifact-name|File content preview is not wired yet" | head -n 20 || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_PREVIEW_MODAL_VERIFY.txt

git add "$TARGET"

git add PHASE719_ADD_PREVIEW_MODAL_FRONTEND_ONLY.sh

git add checkpoints/PHASE719_PHASE530_PRE_PREVIEW_MODAL.js

git add checkpoints/PHASE719_PHASE530_POST_PREVIEW_MODAL.js

git add checkpoints/PHASE719_PREVIEW_MODAL_VERIFY.txt

git commit -m "Phase 719: add frontend-only artifact preview modal"

git push origin "$BRANCH"

echo "===== PREVIEW MODAL PATCH COMPLETE ====="

