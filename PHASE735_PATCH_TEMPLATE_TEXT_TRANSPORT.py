
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

text = text.replace(

    '<template data-phase735-visual-html-template="true">${safeVisualHtml}</template>',

    '<template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeVisualHtml)}</template>'

)

text = text.replace(

    '<template data-phase735-visual-html-template="true">${safeFallbackHtml}</template>',

    '<template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeFallbackHtml)}</template>'

)

text = text.replace(

    'const templateHtml = template ? template.innerHTML : "";',

    'const templateHtml = template ? template.textContent : "";'

)

path.write_text(text)

print("patched template transport to escaped textContent")

