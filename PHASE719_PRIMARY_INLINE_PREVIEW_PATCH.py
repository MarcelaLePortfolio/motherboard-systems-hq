
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''  function phase719RenderMarkdownArtifactPreview(markdown) {

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

new = '''  function phase719RenderMarkdownArtifactPreview(markdown) {

    const rendered = phase719RenderArtifactVisualCard(markdown);

    return `

      <div data-phase719-preview-stack="true" style="display:grid;gap:12px;">

        <div data-phase719-inline-preview-primary="true" style="border:1px solid rgba(96,165,250,.22);border-radius:16px;padding:0;background:rgba(15,23,42,.34);">

          ${rendered}

        </div>

      </div>

    `;

  }

'''

if old not in text:

    raise SystemExit("Target inline fallback render block not found. No changes applied.")

text = text.replace(old, new, 1)

path.write_text(text)

