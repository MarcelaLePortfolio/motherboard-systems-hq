
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

anchor = '''    const semanticPriority = semanticSource.includes("failed") || semanticSource.includes("blocked") || semanticSource.includes("error")

      ? "Needs Review"

      : semanticSource.includes("next") || semanticSource.includes("recommend")

        ? "Actionable"

        : "Informational";

    const enrichedSections = [

'''

insert = '''    function phase719CleanRepeatedArtifactText(value) {

      const raw = String(value || "").trim();

      const standardPrefix = "Standard execution prepared for:";

      if (raw.startsWith(standardPrefix)) {

        return raw.replace(standardPrefix, "Prepared artifact for:").trim();

      }

      return raw;

    }

    const displaySummary = phase719CleanRepeatedArtifactText(summary);

    const displayDeliverable = phase719CleanRepeatedArtifactText(deliverable);

    const displayOutcome = phase719CleanRepeatedArtifactText(outcome);

    const enrichedSections = [

'''

if anchor not in text:

    raise SystemExit("Semantic priority anchor not found. No changes applied.")

text = text.replace(anchor, anchor.replace("    const enrichedSections = [", "") + insert, 1)

text = text.replace('''      ["Summary", summary],

      ["Deliverable", deliverable],

''', '''      ["Summary", displaySummary],

      ["Deliverable", displayDeliverable],

''', 1)

text = text.replace('''${phase719EscapePreviewHtml(outcome || "No outcome content available.")}''', '''${phase719EscapePreviewHtml(displayOutcome || "No outcome content available.")}''', 1)

path.write_text(text)

