
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old_mount = '''          <div

            data-phase735-visual-html-mount="true"

            data-phase735-visual-html="${encodeURIComponent(safeVisualHtml)}"

          ></div>'''

new_mount = '''          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${safeVisualHtml}</template>'''

if old_mount not in text:

    raise SystemExit("attribute mount block not found")

text = text.replace(old_mount, new_mount, 1)

old_callback = '''      body.querySelectorAll("[data-phase735-visual-html-mount]").forEach((phase735Mount) => {

        const encoded = phase735Mount.getAttribute("data-phase735-visual-html") || "";

        try {

          const decoded = decodeURIComponent(encoded);

          phase735Mount.innerHTML = phase723SanitizeVisualArtifactHtml(decoded);

        } catch (error) {

          phase735Mount.textContent = "Unable to render artifact preview.";

        }

      });'''

new_callback = '''      body.querySelectorAll("[data-phase735-visual-html-mount]").forEach((phase735Mount) => {

        const template = phase735Mount.parentElement

          ? phase735Mount.parentElement.querySelector("[data-phase735-visual-html-template]")

          : null;

        const templateHtml = template ? template.innerHTML : "";

        try {

          const decoded = phase735DecodeVisualArtifactHtmlTransport(templateHtml);

          phase735Mount.innerHTML = phase723SanitizeVisualArtifactHtml(decoded);

          if (template) template.remove();

        } catch (error) {

          phase735Mount.textContent = "Unable to render artifact preview.";

        }

      });'''

if old_callback not in text:

    raise SystemExit("attribute mount callback not found")

text = text.replace(old_callback, new_callback, 1)

path.write_text(text)

print("patched visual artifact template mount")

