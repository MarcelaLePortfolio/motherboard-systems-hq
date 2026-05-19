
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''    const rendered = phase719RenderArtifactVisualCard(markdown);

    return `

      <div data-phase719-preview-stack="true" style="display:grid;gap:12px;">

        <div data-phase719-inline-preview-primary="true" style="border:1px solid rgba(96,165,250,.22);border-radius:16px;padding:0;background:rgba(15,23,42,.34);">

          ${rendered}

        </div>

      </div>

    `;

'''

new = '''    const rendered = phase719RenderArtifactVisualCard(markdown);

    const previewTheme = phase733BuildPreviewThemeFromStyleIntent(

      semanticEnvelope?.style_intent || {}

    );

    return `

      <div data-phase719-preview-stack="true" style="display:grid;gap:12px;">

        <div

          data-phase719-inline-preview-primary="true"

          style="

            border:1px solid ${previewTheme.cardBorder};

            border-radius:16px;

            padding:0;

            background:${previewTheme.shell};

            box-shadow:${previewTheme.shadow};

          "

        >

          ${rendered}

        </div>

      </div>

    `;

'''

if old not in text:

    raise SystemExit("target block not found")

path.write_text(text.replace(old, new))

print("patched preview shell theme")

