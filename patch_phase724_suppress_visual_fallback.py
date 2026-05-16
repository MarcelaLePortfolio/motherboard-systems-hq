
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''  function phase719RenderMarkdownArtifactPreview(markdown) {

    const rendered = phase723RenderVisualArtifactPreviewCandidate(markdown);

    return `

      <div data-phase719-preview-stack="true" style="display:grid;gap:12px;">

        <div data-phase719-inline-preview-primary="true" style="border:1px solid rgba(96,165,250,.22);border-radius:16px;padding:0;background:rgba(15,23,42,.34);">

          ${rendered}

        </div>

      </div>

    `;

  }

'''

new = '''  function phase719RenderMarkdownArtifactPreview(markdown) {

    const visualCandidate = phase723RenderVisualArtifactPreviewCandidate(markdown);

    const extractedVisual = phase723ExtractVisualArtifactBlock(markdown);

    if (extractedVisual.hasVisualArtifact) {

      return `

        <div data-phase724-visual-only-preview="true" style="display:grid;gap:12px;">

          ${visualCandidate}

        </div>

      `;

    }

    const rendered = visualCandidate;

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

    raise SystemExit("Expected phase719RenderMarkdownArtifactPreview block not found.")

path.write_text(text.replace(old, new, 1))

