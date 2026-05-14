
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: RENDER MARKDOWN ARTIFACT PREVIEW VISUALLY ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="public/js/phase530_visible_panels_bridge.js"

OUT="checkpoints/PHASE719_RENDERED_MARKDOWN_ARTIFACT_PREVIEW_VERIFY.txt"

cp "$TARGET" checkpoints/PHASE719_PHASE530_PRE_RENDERED_MARKDOWN_PREVIEW.js

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old_body = '''        <pre id="phase719-preview-body" style="white-space:pre-wrap;overflow-wrap:anywhere;font-size:12px;line-height:1.55;color:#dbeafe;border:1px solid rgba(96,165,250,.24);background:rgba(15,23,42,.65);border-radius:12px;padding:12px;margin:0;"></pre>'''

new_body = '''        <div id="phase719-preview-body" style="overflow-wrap:anywhere;font-size:13px;line-height:1.6;color:#dbeafe;border:1px solid rgba(96,165,250,.24);background:linear-gradient(180deg, rgba(15,23,42,.92), rgba(2,6,23,.74));border-radius:16px;padding:18px;margin:0;box-shadow:inset 0 1px 0 rgba(255,255,255,.04);"></div>'''

if old_body not in text:

    raise SystemExit("Preview body <pre> marker not found; refusing patch.")

text = text.replace(old_body, new_body, 1)

helper_marker = "  async function phase719OpenPreviewModal(button) {"

if helper_marker not in text:

    raise SystemExit("Preview modal function marker not found; refusing helper insertion.")

helper = r'''

  function phase719EscapePreviewHtml(value) {

    return String(value || "")

      .replace(/&/g, "&amp;")

      .replace(/</g, "&lt;")

      .replace(/>/g, "&gt;")

      .replace(/"/g, "&quot;")

      .replace(/'/g, "&#039;");

  }

  function phase719RenderMarkdownArtifactPreview(markdown) {

    const source = String(markdown || "").trim();

    if (!source) {

      return `<div style="color:#94a3b8;">Artifact file was loaded, but it contained no previewable content.</div>`;

    }

    const lines = source.split(/\r?\n/);

    const html = [];

    let inCode = false;

    let codeLines = [];

    let listOpen = false;

    function closeList() {

      if (listOpen) {

        html.push("</ul>");

        listOpen = false;

      }

    }

    function flushCode() {

      if (inCode) {

        html.push(`<pre style="margin:14px 0 0 0;padding:14px;border-radius:12px;background:rgba(2,6,23,.92);border:1px solid rgba(148,163,184,.22);color:#cbd5e1;white-space:pre-wrap;overflow:auto;font-size:12px;line-height:1.5;">${phase719EscapePreviewHtml(codeLines.join("\n"))}</pre>`);

        codeLines = [];

        inCode = false;

      }

    }

    for (const rawLine of lines) {

      const line = rawLine.trimEnd();

      if (line.trim().startsWith("```")) {

        if (inCode) {

          flushCode();

        } else {

          closeList();

          inCode = true;

          codeLines = [];

        }

        continue;

      }

      if (inCode) {

        codeLines.push(rawLine);

        continue;

      }

      if (!line.trim()) {

        closeList();

        continue;

      }

      if (line.startsWith("# ")) {

        closeList();

        html.push(`<div style="font-size:24px;font-weight:800;letter-spacing:-.02em;color:#f8fafc;margin:0 0 18px 0;">${phase719EscapePreviewHtml(line.slice(2))}</div>`);

        continue;

      }

      if (line.startsWith("## ")) {

        closeList();

        html.push(`<div style="font-size:12px;text-transform:uppercase;letter-spacing:.16em;font-weight:800;color:#93c5fd;margin:22px 0 8px 0;">${phase719EscapePreviewHtml(line.slice(3))}</div>`);

        continue;

      }

      if (line.startsWith("### ")) {

        closeList();

        html.push(`<div style="font-size:15px;font-weight:800;color:#e0f2fe;margin:18px 0 8px 0;">${phase719EscapePreviewHtml(line.slice(4))}</div>`);

        continue;

      }

      if (/^[-*]\s+/.test(line)) {

        if (!listOpen) {

          html.push(`<ul style="margin:8px 0 12px 20px;padding:0;color:#dbeafe;">`);

          listOpen = true;

        }

        html.push(`<li style="margin:6px 0;">${phase719EscapePreviewHtml(line.replace(/^[-*]\s+/, ""))}</li>`);

        continue;

      }

      closeList();

      html.push(`<p style="margin:8px 0 14px 0;color:#dbeafe;font-size:14px;line-height:1.65;">${phase719EscapePreviewHtml(line)}</p>`);

    }

    flushCode();

    closeList();

    return `<div data-phase719-rendered-artifact-preview="true" style="max-width:900px;margin:0 auto;">${html.join("\n")}</div>`;

  }

'''

text = text.replace(helper_marker, helper + helper_marker, 1)

old_loading = 'body.textContent = "Loading rendered artifact preview…";'

new_loading = 'body.innerHTML = `<div style="color:#93c5fd;font-size:14px;">Loading rendered artifact preview…</div>`;'

text = text.replace(old_loading, new_loading, 1)

old_content = 'body.textContent = data.content || "Artifact file was loaded, but it contained no previewable content.";'

new_content = 'body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);'

if old_content not in text:

    raise SystemExit("Artifact content assignment marker not found; refusing patch.")

text = text.replace(old_content, new_content, 1)

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" checkpoints/PHASE719_PHASE530_POST_RENDERED_MARKDOWN_PREVIEW.js

docker compose up -d --build dashboard

sleep 5

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "PREVIEW ROUTE SAMPLE"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/t_3e163cb2-999d-4cdb-b618-baad85cff46c/artifact-preview' | head -n 80 || true

  echo ""

  echo "STATIC JS RENDER MARKERS"

  curl -s --max-time 10 'http://localhost:3000/js/phase530_visible_panels_bridge.js' | grep -nE 'phase719RenderMarkdownArtifactPreview|data-phase719-rendered-artifact-preview|phase719EscapePreviewHtml|Loading rendered artifact preview' | head -n 60 || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 140 motherboard_systems_hq-dashboard-1 || true

} | tee "$OUT"

git add "$TARGET"

git add PHASE719_RENDER_MARKDOWN_ARTIFACT_PREVIEW_VISUALLY.sh

git add checkpoints/PHASE719_PHASE530_PRE_RENDERED_MARKDOWN_PREVIEW.js

git add checkpoints/PHASE719_PHASE530_POST_RENDERED_MARKDOWN_PREVIEW.js

git add "$OUT"

git commit -m "Phase 719: render markdown artifact preview visually"

git push origin "$BRANCH"

echo "===== RENDER MARKDOWN ARTIFACT PREVIEW VISUALLY COMPLETE ====="

