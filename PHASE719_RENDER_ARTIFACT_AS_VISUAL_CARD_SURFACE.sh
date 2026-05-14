
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: RENDER ARTIFACT AS VISUAL CARD SURFACE ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="public/js/phase530_visible_panels_bridge.js"

OUT="checkpoints/PHASE719_VISUAL_CARD_ARTIFACT_SURFACE_VERIFY.txt"

cp "$TARGET" checkpoints/PHASE719_PHASE530_PRE_VISUAL_CARD_ARTIFACT_SURFACE.js

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

start = text.find("  function phase719RenderMarkdownArtifactPreview(markdown) {")

if start == -1:

    raise SystemExit("phase719RenderMarkdownArtifactPreview not found")

end = text.find("\n  async function phase719OpenPreviewModal(button) {", start)

if end == -1:

    raise SystemExit("phase719OpenPreviewModal marker not found")

new_func = r'''  function phase719ExtractArtifactSections(markdown) {

    const source = String(markdown || "");

    const withoutTrace = source.replace(/## Execution Trace[\s\S]*$/i, "").trim();

    const sections = {};

    let current = "intro";

    sections[current] = [];

    withoutTrace.split(/\r?\n/).forEach((line) => {

      const h2 = line.match(/^##\s+(.+?)\s*$/);

      if (h2) {

        current = h2[1].trim().toLowerCase();

        sections[current] = [];

        return;

      }

      if (/^#\s+/.test(line)) {

        sections.title = [line.replace(/^#\s+/, "").trim()];

        return;

      }

      if (!sections[current]) sections[current] = [];

      sections[current].push(line);

    });

    Object.keys(sections).forEach((key) => {

      sections[key] = sections[key].join("\n").trim();

    });

    return sections;

  }

  function phase719RenderArtifactVisualCard(markdown) {

    const sections = phase719ExtractArtifactSections(markdown);

    const title = sections.title || "Task Artifact";

    const task = sections.task || "";

    const status = sections.status || "";

    const outcome = sections.outcome || "";

    const explanation = sections.explanation || "";

    const chips = [

      status ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(134,239,172,.38);background:rgba(20,83,45,.22);color:#bbf7d0;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(status)}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">Rendered Preview</span>`

    ].filter(Boolean).join("");

    return `

      <div data-phase719-rendered-artifact-preview="true" style="max-width:920px;margin:0 auto;">

        <div style="border:1px solid rgba(148,163,184,.22);border-radius:22px;overflow:hidden;background:radial-gradient(circle at top left, rgba(59,130,246,.18), transparent 34%),linear-gradient(180deg, rgba(15,23,42,.96), rgba(2,6,23,.9));box-shadow:0 24px 70px rgba(0,0,0,.42), inset 0 1px 0 rgba(255,255,255,.05);">

          <div style="padding:28px 30px 22px 30px;border-bottom:1px solid rgba(148,163,184,.16);">

            <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:18px;">${chips}</div>

            <div style="font-size:30px;line-height:1.05;font-weight:900;letter-spacing:-.04em;color:#f8fafc;margin-bottom:12px;">${phase719EscapePreviewHtml(title)}</div>

            ${task ? `<div style="font-size:15px;line-height:1.55;color:#cbd5e1;max-width:760px;">${phase719EscapePreviewHtml(task)}</div>` : ""}

          </div>

          <div style="display:grid;grid-template-columns:minmax(0,1.2fr) minmax(220px,.8fr);gap:18px;padding:22px 24px 24px 24px;">

            <section style="border:1px solid rgba(96,165,250,.22);border-radius:18px;background:rgba(15,23,42,.7);padding:18px;">

              <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#93c5fd;font-weight:900;margin-bottom:10px;">Outcome</div>

              <div style="font-size:17px;line-height:1.55;color:#e0f2fe;font-weight:650;">${phase719EscapePreviewHtml(outcome || "No outcome content available.")}</div>

            </section>

            <section style="border:1px solid rgba(45,212,191,.20);border-radius:18px;background:rgba(6,78,59,.16);padding:18px;">

              <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#5eead4;font-weight:900;margin-bottom:10px;">Build Path</div>

              <div style="font-size:14px;line-height:1.55;color:#ccfbf1;">${phase719EscapePreviewHtml(explanation || "No explanation available.")}</div>

            </section>

          </div>

        </div>

      </div>

    `;

  }

  function phase719RenderMarkdownArtifactPreview(markdown) {

    return phase719RenderArtifactVisualCard(markdown);

  }

'''

text = text[:start] + new_func + text[end:]

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" checkpoints/PHASE719_PHASE530_POST_VISUAL_CARD_ARTIFACT_SURFACE.js

docker compose up -d --build dashboard

sleep 5

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "STATIC JS VISUAL CARD MARKERS"

  curl -s --max-time 10 'http://localhost:3000/js/phase530_visible_panels_bridge.js' | grep -nE 'phase719RenderArtifactVisualCard|phase719ExtractArtifactSections|Rendered Preview|Execution Trace|data-phase719-rendered-artifact-preview' | head -n 80 || true

  echo ""

  echo "PREVIEW ROUTE SAMPLE"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/t_3e163cb2-999d-4cdb-b618-baad85cff46c/artifact-preview' | head -n 80 || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 100 motherboard_systems_hq-dashboard-1 || true

} | tee "$OUT"

git add "$TARGET"

git add PHASE719_RENDER_ARTIFACT_AS_VISUAL_CARD_SURFACE.sh

git add checkpoints/PHASE719_PHASE530_PRE_VISUAL_CARD_ARTIFACT_SURFACE.js

git add checkpoints/PHASE719_PHASE530_POST_VISUAL_CARD_ARTIFACT_SURFACE.js

git add "$OUT"

git commit -m "Phase 719: render artifact preview as visual card surface"

git push origin "$BRANCH"

echo "===== VISUAL CARD ARTIFACT SURFACE COMPLETE ====="

