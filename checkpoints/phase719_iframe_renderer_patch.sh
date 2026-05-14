
#!/bin/bash

set -e

echo "===== PHASE 719 IFRAME RENDERER PATCH ====="

TARGET="public/js/phase530_visible_panels_bridge.js"

cp "$TARGET" "${TARGET}.phase719_iframe_backup"

python3 << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

anchor = """

function renderArtifactPreviewContent(content) {

"""

if "function renderArtifactIframePreview" in text:

    raise SystemExit("Iframe renderer already exists. Aborting.")

insertion = """

function renderArtifactIframePreview(html) {

  const safeHtml = `

    <!DOCTYPE html>

    <html>

      <head>

        <style>

          body {

            margin: 0;

            padding: 16px;

            background: #0f172a;

            color: #e2e8f0;

            font-family: Inter, system-ui, sans-serif;

            overflow-wrap: break-word;

          }

          pre {

            white-space: pre-wrap;

          }

          code {

            white-space: pre-wrap;

          }

          * {

            max-width: 100%;

            box-sizing: border-box;

          }

        </style>

      </head>

      <body>

        ${html}

      </body>

    </html>

  `;

  return `

    <iframe

      class="artifact-preview-iframe"

      sandbox="allow-same-origin"

      srcdoc="${safeHtml

        .replace(/&/g, '&amp;')

        .replace(/"/g, '&quot;')}"

      style="

        width: 100%;

        min-height: 480px;

        border: 1px solid rgba(148,163,184,0.2);

        border-radius: 12px;

        background: #0f172a;

      "

    ></iframe>

  `;

}

"""

text = text.replace(anchor, insertion + anchor)

old = """

  return `

    <div class="artifact-preview-rendered">

      ${rendered}

    </div>

  `;

"""

new = """

  return `

    <div class="artifact-preview-rendered">

      ${renderArtifactIframePreview(rendered)}

    </div>

  `;

"""

if old not in text:

    raise SystemExit("Target render block not found. Aborting.")

text = text.replace(old, new)

path.write_text(text)

print("Iframe renderer injected successfully.")

PY

echo ""

echo "===== PATCH COMPLETE ====="

echo ""

echo "NEXT:"

echo "1. rebuild dashboard"

echo "2. validate preview modal"

echo "3. validate retry/requeue"

echo "4. validate SSE"

echo "5. rollback immediately if instability appears"

