
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: WIRE PREVIEW MODAL TO ARTIFACT CONTENT ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="public/js/phase530_visible_panels_bridge.js"

OUT="checkpoints/PHASE719_PREVIEW_MODAL_CONTENT_FETCH_VERIFY.txt"

cp "$TARGET" checkpoints/PHASE719_PHASE530_PRE_PREVIEW_MODAL_CONTENT_FETCH.js

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''  async function phase719OpenPreviewModal(button) {

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

    ].filter(Boolean).join("\\n");

    body.textContent = [

      outcome ? "Outcome:\\n" + outcome : "",

      explanation ? "Explanation:\\n" + explanation : "",

      !outcome && !explanation ? "Artifact metadata is available. File content preview is not wired yet." : ""

    ].filter(Boolean).join("\\n\\n");

    modal.style.display = "flex";

  }

'''

new = '''  async function phase719OpenPreviewModal(button) {

    const modal = phase719EnsurePreviewModal();

    const title = modal.querySelector("#phase719-preview-title");

    const subtitle = modal.querySelector("#phase719-preview-subtitle");

    const meta = modal.querySelector("#phase719-preview-meta");

    const body = modal.querySelector("#phase719-preview-body");

    const taskTitle = button.getAttribute("data-task-title") || "Artifact Preview";

    const taskId = button.getAttribute("data-task-id") || "";

    const fallbackName = button.getAttribute("data-artifact-name") || "artifact";

    const fallbackType = button.getAttribute("data-artifact-type") || "artifact";

    const fallbackSize = button.getAttribute("data-artifact-size") || "";

    const fallbackPath = button.getAttribute("data-artifact-path") || "";

    const fallbackOutcome = button.getAttribute("data-artifact-outcome") || "";

    const fallbackExplanation = button.getAttribute("data-artifact-explanation") || "";

    title.textContent = "Preview: " + taskTitle;

    subtitle.textContent = taskId ? "task_id: " + taskId : "";

    meta.textContent = [

      "artifact: " + fallbackName,

      fallbackType ? "type: " + fallbackType : "",

      fallbackSize ? "size: " + fallbackSize : "",

      fallbackPath ? "path: " + fallbackPath : ""

    ].filter(Boolean).join("\\n");

    body.textContent = "Loading rendered artifact preview…";

    modal.style.display = "flex";

    if (!taskId) {

      body.textContent = "No task id available for artifact preview.";

      return;

    }

    try {

      const res = await fetch(`/api/tasks/${encodeURIComponent(taskId)}/artifact-preview`, { cache: "no-store" });

      const data = await res.json().catch(() => null);

      if (!res.ok || !data || data.ok !== true) {

        body.textContent = [

          "Rendered artifact content is not available.",

          data && data.error ? "Error: " + data.error : "",

          fallbackOutcome ? "\\nOutcome:\\n" + fallbackOutcome : "",

          fallbackExplanation ? "\\nExplanation:\\n" + fallbackExplanation : ""

        ].filter(Boolean).join("\\n");

        return;

      }

      const artifact = data.artifact || {};

      const renderedName = artifact.filename || fallbackName;

      const renderedType = artifact.type || fallbackType;

      const renderedSize = artifact.size_bytes ? String(artifact.size_bytes) + " bytes" : fallbackSize;

      const renderedCreated = artifact.created_at || "";

      meta.textContent = [

        "artifact: " + renderedName,

        renderedType ? "type: " + renderedType : "",

        renderedSize ? "size: " + renderedSize : "",

        renderedCreated ? "created: " + renderedCreated : ""

      ].filter(Boolean).join("\\n");

      body.textContent = data.content || "Artifact file was loaded, but it contained no previewable content.";

    } catch (error) {

      body.textContent = [

        "Preview fetch failed.",

        error && error.message ? error.message : String(error),

        fallbackOutcome ? "\\nOutcome:\\n" + fallbackOutcome : "",

        fallbackExplanation ? "\\nExplanation:\\n" + fallbackExplanation : ""

      ].filter(Boolean).join("\\n");

    }

  }

'''

if old not in text:

    raise SystemExit("Exact preview modal function block not found; refusing patch.")

text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" checkpoints/PHASE719_PHASE530_POST_PREVIEW_MODAL_CONTENT_FETCH.js

docker compose up -d --build dashboard

sleep 5

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "PREVIEW ROUTE SAMPLE"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/t_3e163cb2-999d-4cdb-b618-baad85cff46c/artifact-preview' | head -n 100 || true

  echo ""

  echo "STATIC JS FETCH MARKERS"

  curl -s --max-time 10 'http://localhost:3000/js/phase530_visible_panels_bridge.js' | grep -nE 'artifact-preview|Loading rendered artifact preview|Rendered artifact content is not available|Preview fetch failed' | head -n 40 || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 140 motherboard_systems_hq-dashboard-1 || true

} | tee "$OUT"

git add "$TARGET"

git add PHASE719_WIRE_PREVIEW_MODAL_TO_ARTIFACT_CONTENT.sh

git add checkpoints/PHASE719_PHASE530_PRE_PREVIEW_MODAL_CONTENT_FETCH.js

git add checkpoints/PHASE719_PHASE530_POST_PREVIEW_MODAL_CONTENT_FETCH.js

git add "$OUT"

git commit -m "Phase 719: wire preview modal to artifact content"

git push origin "$BRANCH"

echo "===== PREVIEW MODAL CONTENT FETCH COMPLETE ====="

