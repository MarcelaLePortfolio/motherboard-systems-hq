
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''  function phase719RenderMarkdownArtifactPreview(markdown) {

    const rendered = phase719RenderArtifactVisualCard(markdown);

    return phase719RenderArtifactIframePreview(rendered);

  }

'''

new = '''  function phase719RenderMarkdownArtifactPreview(markdown) {

    const rendered = phase719RenderArtifactVisualCard(markdown);

    const iframePreview = phase719RenderArtifactIframePreview(rendered);

    return `

      <div data-phase719-preview-stack="true" style="display:grid;gap:12px;">

        ${iframePreview}

        <div data-phase719-inline-preview-fallback="true" style="border:1px solid rgba(251,191,36,.24);border-radius:16px;padding:10px;background:rgba(120,53,15,.10);">

          <div style="font-size:11px;text-transform:uppercase;letter-spacing:.14em;color:#fde68a;font-weight:900;margin-bottom:8px;">Inline fallback preview</div>

          ${rendered}

        </div>

      </div>

    `;

  }

'''

if old not in text:

    raise SystemExit("Target render function not found. No changes applied.")

text = text.replace(old, new, 1)

path.write_text(text)

