
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''  function phase723ExtractVisualArtifactBlock(markdown) {

    const source = phase733NormalizePreviewTransportText(markdown);'''

new = '''  function phase723ExtractVisualArtifactBlock(markdown) {

    const normalized = phase733NormalizePreviewTransportText(markdown);

    const source = phase720StripSemanticEnvelope(normalized);'''

if old not in text:

    raise SystemExit("target extraction source block not found")

path.write_text(text.replace(old, new))

print("patched visual artifact extraction to ignore semantic envelope")

