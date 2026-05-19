
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''      body.innerHTML = phase719RenderMarkdownArtifactPreview(markdown);'''

new = '''      body.innerHTML = phase719RenderMarkdownArtifactPreview(markdown);

      const phase735Mount = body.querySelector("[data-phase735-visual-html-mount]");

      if (phase735Mount) {

        const encoded = phase735Mount.getAttribute("data-phase735-visual-html") || "";

        try {

          const decoded = decodeURIComponent(encoded);

          phase735Mount.innerHTML = phase723SanitizeVisualArtifactHtml(decoded);

        } catch (error) {

          phase735Mount.textContent = "Unable to render artifact preview.";

        }

      }'''

if old not in text:

    raise SystemExit("modal render assignment not found")

text = text.replace(old, new, 1)

old_container = '''          ${safeVisualHtml}'''

new_container = '''          <div

            data-phase735-visual-html-mount="true"

            data-phase735-visual-html="${encodeURIComponent(safeVisualHtml)}"

          ></div>'''

if old_container not in text:

    raise SystemExit("safe visual html insertion target not found")

text = text.replace(old_container, new_container, 1)

path.write_text(text)

print("patched visual artifact DOM mount")

