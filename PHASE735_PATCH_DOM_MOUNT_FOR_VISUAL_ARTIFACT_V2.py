
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old_assignment = "      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);"

new_assignment = '''      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);

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

if old_assignment not in text:

    raise SystemExit("actual modal render assignment not found")

text = text.replace(old_assignment, new_assignment, 1)

old_insertion = "          ${safeVisualHtml}"

new_insertion = '''          <div

            data-phase735-visual-html-mount="true"

            data-phase735-visual-html="${encodeURIComponent(safeVisualHtml)}"

          ></div>'''

if old_insertion not in text:

    raise SystemExit("safeVisualHtml insertion target not found")

text = text.replace(old_insertion, new_insertion, 1)

path.write_text(text)

print("patched visual artifact DOM mount v2")

