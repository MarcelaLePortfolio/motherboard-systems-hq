
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

if "function phase733BuildPreviewThemeFromStyleIntent" not in text:

    anchor = '''  function phase733NormalizePreviewTransportText(value) {

    return String(value || "")

      .replace(/\\\\r\\\\n/g, "\\n")

      .replace(/\\\\n/g, "\\n")

      .replace(/\\\\t/g, "  ");

  }

'''

    helper = '''  function phase733BuildPreviewThemeFromStyleIntent(styleIntent) {

    const baseTheme = {

      shell: "radial-gradient(circle at top left, rgba(59,130,246,.18), transparent 34%),linear-gradient(180deg, rgba(15,23,42,.96), rgba(2,6,23,.9))",

      border: "rgba(148,163,184,.22)",

      heading: "#f8fafc",

      body: "#e0f2fe",

      secondary: "#cbd5e1",

      card: "rgba(15,23,42,.7)",

      cardBorder: "rgba(96,165,250,.22)",

      accent: "#93c5fd",

      insight: "rgba(6,78,59,.18)",

      insightBorder: "rgba(45,212,191,.24)",

      insightText: "#ccfbf1",

      shadow: "0 24px 70px rgba(0,0,0,.42), inset 0 1px 0 rgba(255,255,255,.05)"

    };

    if (!styleIntent || typeof styleIntent !== "object") return baseTheme;

    const values = Object.values(styleIntent).map((value) => String(value || "").toLowerCase()).join(" ");

    const wantsSoftGarden = [

      "cream",

      "blush",

      "ivory",

      "plum",

      "mauve",

      "sage",

      "honey",

      "gold",

      "lavender",

      "garden",

      "cozy",

      "cute",

      "soft",

      "magical",

      "rounded"

    ].some((token) => values.includes(token));

    if (!wantsSoftGarden) return baseTheme;

    return {

      shell: "linear-gradient(135deg, #fff7ed 0%, #fdf2f8 46%, #f5f3ff 100%)",

      border: "rgba(190,128,143,.35)",

      heading: "#4a2438",

      body: "#5b3748",

      secondary: "#7b5a68",

      card: "rgba(255,252,247,.88)",

      cardBorder: "rgba(190,128,143,.28)",

      accent: "#8f5f76",

      insight: "rgba(236,253,245,.78)",

      insightBorder: "rgba(134,170,132,.32)",

      insightText: "#35523f",

      shadow: "0 22px 55px rgba(126,75,92,.16), inset 0 1px 0 rgba(255,255,255,.72)"

    };

  }

'''

    if anchor not in text:

        raise SystemExit("Normalize helper anchor not found")

    text = text.replace(anchor, anchor + helper, 1)

old = '''    const semanticEnvelope = phase720ExtractSemanticEnvelope(markdown);

    const markdownWithoutEnvelope = phase720StripSemanticEnvelope(markdown);

    const sections = phase719ExtractArtifactSections(markdownWithoutEnvelope);'''

new = '''    const semanticEnvelope = phase720ExtractSemanticEnvelope(markdown);

    const markdownWithoutEnvelope = phase720StripSemanticEnvelope(markdown);

    const phase733Theme = phase733BuildPreviewThemeFromStyleIntent(semanticEnvelope && semanticEnvelope.style_intent);

    const sections = phase719ExtractArtifactSections(markdownWithoutEnvelope);'''

if old in text:

    text = text.replace(old, new, 1)

replacements = {

    'border:1px solid rgba(148,163,184,.22);border-radius:22px;overflow:hidden;background:radial-gradient(circle at top left, rgba(59,130,246,.18), transparent 34%),linear-gradient(180deg, rgba(15,23,42,.96), rgba(2,6,23,.9));box-shadow:0 24px 70px rgba(0,0,0,.42), inset 0 1px 0 rgba(255,255,255,.05);':

    'border:1px solid ${phase733Theme.border};border-radius:22px;overflow:hidden;background:${phase733Theme.shell};box-shadow:${phase733Theme.shadow};',

    'color:#f8fafc;margin-bottom:12px;':

    'color:${phase733Theme.heading};margin-bottom:12px;',

    'color:#cbd5e1;max-width:760px;':

    'color:${phase733Theme.secondary};max-width:760px;',

    'border:1px solid rgba(45,212,191,.24);border-radius:18px;background:rgba(6,78,59,.18);padding:18px;':

    'border:1px solid ${phase733Theme.insightBorder};border-radius:18px;background:${phase733Theme.insight};padding:18px;',

    'color:#ccfbf1;white-space:pre-wrap;':

    'color:${phase733Theme.insightText};white-space:pre-wrap;',

    'border:1px solid rgba(96,165,250,.22);border-radius:18px;background:rgba(15,23,42,.7);padding:18px;':

    'border:1px solid ${phase733Theme.cardBorder};border-radius:18px;background:${phase733Theme.card};padding:18px;',

    'color:#93c5fd;font-weight:900;margin-bottom:10px;':

    'color:${phase733Theme.accent};font-weight:900;margin-bottom:10px;',

    'color:#e0f2fe;white-space:pre-wrap;':

    'color:${phase733Theme.body};white-space:pre-wrap;',

    'color:#e0f2fe;font-weight:650;':

    'color:${phase733Theme.body};font-weight:650;',

    'border:1px solid rgba(45,212,191,.20);border-radius:18px;background:rgba(6,78,59,.16);padding:18px;':

    'border:1px solid ${phase733Theme.insightBorder};border-radius:18px;background:${phase733Theme.insight};padding:18px;'

}

for before, after in replacements.items():

    text = text.replace(before, after)

path.write_text(text)

