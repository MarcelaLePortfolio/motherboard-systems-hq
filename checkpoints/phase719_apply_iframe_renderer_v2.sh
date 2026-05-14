
#!/bin/bash

set -e

echo "===== PHASE 719 APPLY IFRAME RENDERER V2 ====="

TARGET="public/js/phase530_visible_panels_bridge.js"

rm -f "${TARGET}.phase719_iframe_backup"

cp "$TARGET" "${TARGET}.phase719_iframe_v2_backup"

python3 << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

if "function phase719RenderArtifactIframePreview" in text:

    raise SystemExit("Iframe renderer already exists. Aborting to avoid duplicate patch.")

anchor = "  function phase719RenderMarkdownArtifactPreview(markdown) {\n\n    return phase719RenderArtifactVisualCard(markdown);\n\n  }\n"

if anchor not in text:

    raise SystemExit("Expected markdown preview function block not found. Aborting.")

replacement = """  function phase719RenderArtifactIframePreview(renderedHtml) {

    const srcdoc = [

      "<!DOCTYPE html>",

      "<html>",

      "<head>",

      "<meta charset=\\\"utf-8\\\">",

      "<style>",

      "html,body{margin:0;padding:0;background:#020617;color:#e5e7eb;font-family:Inter,system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;}",

      "body{padding:18px;overflow-wrap:anywhere;}",

      "*{box-sizing:border-box;max-width:100%;}",

      "</style>",

      "</head>",

      "<body>",

      String(renderedHtml || ""),

      "</body>",

      "</html>"

    ].join("");

    return `

      <iframe

        title="Artifact rendered preview"

        sandbox=""

        srcdoc="${phase719EscapePreviewHtml(srcdoc)}"

        style="display:block;width:100%;min-height:560px;border:1px solid rgba(148,163,184,.24);border-radius:16px;background:#020617;"

      ></iframe>

    `;

  }

  function phase719RenderMarkdownArtifactPreview(markdown) {

    const rendered = phase719RenderArtifactVisualCard(markdown);

    return phase719RenderArtifactIframePreview(rendered);

  }

"""

text = text.replace(anchor, replacement)

path.write_text(text)

print("Iframe renderer V2 applied successfully.")

PY

echo ""

echo "[1] Verify inserted symbols"

grep -n "phase719RenderArtifactIframePreview\\|phase719RenderMarkdownArtifactPreview\\|sandbox=\\\"\\\"" "$TARGET"

echo ""

echo "[2] Git diff summary"

git diff -- "$TARGET" | sed -n '1,220p'

echo ""

echo "===== PHASE 719 IFRAME RENDERER V2 COMPLETE ====="

