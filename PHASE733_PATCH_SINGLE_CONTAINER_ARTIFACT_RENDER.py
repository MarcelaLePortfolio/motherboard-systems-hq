
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

start = text.index("  function phase719RenderMarkdownArtifactPreview(markdown) {")

end = text.index("  async function phase719OpenPreviewModal(button) {", start)

new_function = r'''  function phase719RenderMarkdownArtifactPreview(markdown) {

    const extractedVisual = phase723ExtractVisualArtifactBlock(markdown);

    if (extractedVisual.hasVisualArtifact) {

      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(extractedVisual.visualHtml);

      return `

        <div

          data-phase733-single-artifact-render="true"

          style="

            max-width:1040px;

            margin:0 auto;

            border:1px solid rgba(148,163,184,.28);

            border-radius:22px;

            padding:18px;

            background:rgba(15,23,42,.42);

            box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.05);

            overflow:auto;

          "

        >

          ${safeVisualHtml}

        </div>

      `;

    }

    return `

      <div

        data-phase733-single-artifact-render-fallback="true"

        style="

          max-width:920px;

          margin:0 auto;

          border:1px solid rgba(148,163,184,.28);

          border-radius:22px;

          padding:22px;

          background:rgba(15,23,42,.72);

          color:#e5e7eb;

          white-space:pre-wrap;

          overflow-wrap:anywhere;

        "

      >${phase719EscapePreviewHtml(phase720StripSemanticEnvelope(markdown))}</div>

    `;

  }

'''

path.write_text(text[:start] + new_function + text[end:])

print("patched preview to single-container artifact render")

