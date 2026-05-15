
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

BACKUP="checkpoints/PHASE720_PRE_FRONTEND_SEMANTIC_DETECTION_V2.js"

echo "===== PHASE 720 FRONTEND SEMANTIC ENVELOPE DETECTION PATCH V2 ====="

cp "$TARGET" "$BACKUP"

python3 << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

if "function phase720ExtractSemanticEnvelope" in text:

    raise SystemExit("Semantic detection helpers already present; aborting to avoid duplicate patch.")

marker = '''  function phase719ExtractArtifactSections(markdown) {

'''

helpers = '''  function phase720ExtractSemanticEnvelope(markdown) {

    const source = String(markdown || "");

    const match = source.match(/<!--\\s*MB_SEMANTIC_ARTIFACT_V1\\s*([\\s\\S]*?)\\s*-->/);

    if (!match || !match[1]) return null;

    try {

      const parsed = JSON.parse(match[1].trim());

      if (!parsed || typeof parsed !== "object") return null;

      return parsed;

    } catch (_e) {

      return null;

    }

  }

  function phase720StripSemanticEnvelope(markdown) {

    return String(markdown || "").replace(/<!--\\s*MB_SEMANTIC_ARTIFACT_V1\\s*[\\s\\S]*?\\s*-->\\s*/g, "");

  }

'''

if marker not in text:

    raise SystemExit("HELPER INSERT MARKER NOT FOUND")

text = text.replace(marker, helpers + marker, 1)

old_sections = '''  function phase719RenderArtifactVisualCard(markdown) {

    const sections = phase719ExtractArtifactSections(markdown);

'''

new_sections = '''  function phase719RenderArtifactVisualCard(markdown) {

    const semanticEnvelope = phase720ExtractSemanticEnvelope(markdown);

    const markdownWithoutEnvelope = phase720StripSemanticEnvelope(markdown);

    const sections = phase719ExtractArtifactSections(markdownWithoutEnvelope);

'''

if old_sections not in text:

    raise SystemExit("VISUAL CARD SECTION TARGET NOT FOUND")

text = text.replace(old_sections, new_sections, 1)

old_chips = '''    const chips = [

      status ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(134,239,172,.38);background:rgba(20,83,45,.22);color:#bbf7d0;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(status)}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticType)}</span>`,

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(251,191,36,.34);background:rgba(120,53,15,.18);color:#fde68a;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticPriority)}</span>`

    ].filter(Boolean).join("");

'''

new_chips = '''    const chips = [

      status ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(134,239,172,.38);background:rgba(20,83,45,.22);color:#bbf7d0;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(status)}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticType)}</span>`,

      semanticEnvelope ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(45,212,191,.34);background:rgba(20,184,166,.14);color:#99f6e4;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">semantic v${phase719EscapePreviewHtml(semanticEnvelope.semantic_version || "1")}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(251,191,36,.34);background:rgba(120,53,15,.18);color:#fde68a;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticPriority)}</span>`

    ].filter(Boolean).join("");

'''

if old_chips not in text:

    raise SystemExit("CHIP TARGET NOT FOUND")

text = text.replace(old_chips, new_chips, 1)

path.write_text(text)

print("Frontend semantic envelope detection V2 patch applied.")

PY

grep -n "phase720ExtractSemanticEnvelope\\|phase720StripSemanticEnvelope\\|semantic v" "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

git add PHASE720_PATCH_FRONTEND_SEMANTIC_DETECTION_V2.sh checkpoints/PHASE720_PRE_FRONTEND_SEMANTIC_DETECTION_V2.js public/js/phase530_visible_panels_bridge.js

git commit -m "Phase 720: add frontend semantic envelope detection v2"

git push origin phase719-artifact-visibility

git status --short

git log --oneline --decorate -6

