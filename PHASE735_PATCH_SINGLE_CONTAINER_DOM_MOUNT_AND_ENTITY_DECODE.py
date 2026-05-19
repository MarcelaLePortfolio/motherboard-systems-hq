
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

insert_after = '''  function phase719RenderMarkdownArtifactPreview(markdown) {'''

helper = '''  function phase735DecodeVisualArtifactHtmlTransport(html) {

    const source = phase733NormalizePreviewTransportText(html || "")

      .replace(/\\\\\\\\n/g, "\\n")

      .replace(/\\\\\\\\\\"/g, '"')

      .replace(/\\\\\\\\'/g, "'");

    const textarea = document.createElement("textarea");

    textarea.innerHTML = source;

    return textarea.value;

  }

'''

if "function phase735DecodeVisualArtifactHtmlTransport" not in text:

    text = text.replace(insert_after, helper + insert_after, 1)

old_decode_block = '''      const decodedVisualHtml = phase733NormalizePreviewTransportText(extractedVisual.visualHtml)

        .replace(/\\\\\\\\n/g, "\\n")

        .replace(/\\\\\\\\\\"/g, '"')

        .replace(/\\\\\\\\'/g, "'");

      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(decodedVisualHtml);'''

new_decode_block = '''      const decodedVisualHtml = phase735DecodeVisualArtifactHtmlTransport(extractedVisual.visualHtml);

      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(decodedVisualHtml);'''

if old_decode_block in text:

    text = text.replace(old_decode_block, new_decode_block, 1)

single_branch_old = '''          ${safeVisualHtml}

        </div>

      `;

    }

    return `'''

single_branch_new = '''          <div

            data-phase735-visual-html-mount="true"

            data-phase735-visual-html="${encodeURIComponent(safeVisualHtml)}"

          ></div>

        </div>

      `;

    }

    return `'''

if single_branch_old in text:

    text = text.replace(single_branch_old, single_branch_new, 1)

old_assignment = '''      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);

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

new_assignment = '''      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);

      body.querySelectorAll("[data-phase735-visual-html-mount]").forEach((phase735Mount) => {

        const encoded = phase735Mount.getAttribute("data-phase735-visual-html") || "";

        try {

          const decoded = decodeURIComponent(encoded);

          phase735Mount.innerHTML = phase723SanitizeVisualArtifactHtml(decoded);

        } catch (error) {

          phase735Mount.textContent = "Unable to render artifact preview.";

        }

      });'''

if old_assignment in text:

    text = text.replace(old_assignment, new_assignment, 1)

elif new_assignment not in text:

    actual_assignment = "      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);"

    text = text.replace(actual_assignment, new_assignment, 1)

path.write_text(text)

print("patched single-container DOM mount and entity decode")

