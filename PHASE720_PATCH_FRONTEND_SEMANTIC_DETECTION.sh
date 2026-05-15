
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

BACKUP="checkpoints/PHASE720_PRE_FRONTEND_SEMANTIC_DETECTION.js"

echo "===== PHASE 720 FRONTEND SEMANTIC ENVELOPE DETECTION PATCH ====="

cp "$TARGET" "$BACKUP"

python3 << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

insert_after = '''  function phase719EscapePreviewHtml(value) {

    return String(value ?? "")

      .replace(/&/g, "&amp;")

      .replace(/</g, "&lt;")

      .replace(/>/g, "&gt;")

      .replace(/"/g, "&quot;")

      .replace(/'/g, "&#39;");

  }

'''

addition = '''  function phase720ExtractSemanticEnvelope(markdown) {

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

if insert_after not in text:

    raise SystemExit("INSERT TARGET NOT FOUND")

text = text.replace(insert_after, insert_after + addition, 1)

old = '''    const sections = phase719ExtractArtifactSections(markdown);

'''

new = '''    const semanticEnvelope = phase720ExtractSemanticEnvelope(markdown);

    const markdownWithoutEnvelope = phase720StripSemanticEnvelope(markdown);

    const sections = phase719ExtractArtifactSections(markdownWithoutEnvelope);

'''

if old not in text:

    raise SystemExit("RENDER TARGET NOT FOUND")

text = text.replace(old, new, 1)

old_chip = '''      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticType)}</span>`,

'''

new_chip = '''      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticType)}</span>`,

      semanticEnvelope ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(45,212,191,.34);background:rgba(20,184,166,.14);color:#99f6e4;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">semantic v${phase719EscapePreviewHtml(semanticEnvelope.semantic_version || "1")}</span>` : "",

'''

if old_chip not in text:

    raise SystemExit("CHIP TARGET NOT FOUND")

text = text.replace(old_chip, new_chip, 1)

path.write_text(text)

print("Frontend semantic envelope detection patch applied.")

PY

grep -n "phase720ExtractSemanticEnvelope\\|phase720StripSemanticEnvelope\\|semantic v" "$TARGET"

echo "===== PATCH COMPLETE ====="

