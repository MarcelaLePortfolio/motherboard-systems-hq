
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''    return `

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

    `;'''

new = '''    const strippedFallback = phase720StripSemanticEnvelope(markdown);

    const decodedFallback = phase735DecodeVisualArtifactHtmlTransport(strippedFallback);

    const fallbackLooksLikeHtml = /<\\s*div\\b|<\\s*section\\b|<\\s*article\\b/i.test(decodedFallback);

    if (fallbackLooksLikeHtml) {

      const safeFallbackHtml = phase723SanitizeVisualArtifactHtml(decodedFallback);

      return `

        <div

          data-phase733-single-artifact-render="true"

          data-phase735-fallback-html-artifact="true"

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

          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${safeFallbackHtml}</template>

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

      >${phase719EscapePreviewHtml(strippedFallback)}</div>

    `;'''

if old not in text:

    raise SystemExit("fallback render block not found")

path.write_text(text.replace(old, new, 1))

print("patched fallback raw HTML artifact render")

