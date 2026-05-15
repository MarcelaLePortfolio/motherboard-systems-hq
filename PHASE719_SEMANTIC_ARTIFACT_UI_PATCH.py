
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''  function phase719RenderArtifactVisualCard(markdown) {

    const sections = phase719ExtractArtifactSections(markdown);

    const title = sections.title || "Task Artifact";

    const task = sections.task || "";

    const status = sections.status || "";

    const summary = sections.summary || "";

    const deliverable = sections.deliverable || "";

    const details = sections.details || "";

    const recommendations = sections.recommendations || "";

    const nextSteps = sections["next steps"] || sections.nextsteps || "";

    const outcome = sections.outcome || "";

    const explanation = sections.explanation || "";

    const enrichedSections = [

      ["Summary", summary],

      ["Deliverable", deliverable],

      ["Details", details],

      ["Recommendations", recommendations],

      ["Next Steps", nextSteps]

    ].filter(([, value]) => String(value || "").trim());

    const chips = [

      status ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(134,239,172,.38);background:rgba(20,83,45,.22);color:#bbf7d0;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(status)}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">Rendered Preview</span>`

    ].filter(Boolean).join("");

'''

new = '''  function phase719RenderArtifactVisualCard(markdown) {

    const sections = phase719ExtractArtifactSections(markdown);

    const title = sections.title || "Task Artifact";

    const task = sections.task || "";

    const status = sections.status || "";

    const summary = sections.summary || "";

    const deliverable = sections.deliverable || "";

    const details = sections.details || "";

    const recommendations = sections.recommendations || "";

    const nextSteps = sections["next steps"] || sections.nextsteps || "";

    const outcome = sections.outcome || "";

    const explanation = sections.explanation || "";

    const semanticSource = [

      title,

      task,

      summary,

      deliverable,

      details,

      recommendations,

      nextSteps,

      outcome,

      explanation

    ].join(" ").toLowerCase();

    const semanticType = semanticSource.includes("error") || semanticSource.includes("failed") || semanticSource.includes("failure")

      ? "Recovery Artifact"

      : semanticSource.includes("next steps") || semanticSource.includes("recommend")

        ? "Execution Plan"

        : semanticSource.includes("completed") || semanticSource.includes("success")

          ? "Completion Summary"

          : "Task Artifact";

    const semanticPriority = semanticSource.includes("failed") || semanticSource.includes("blocked") || semanticSource.includes("error")

      ? "Needs Review"

      : semanticSource.includes("next") || semanticSource.includes("recommend")

        ? "Actionable"

        : "Informational";

    const enrichedSections = [

      ["Summary", summary],

      ["Deliverable", deliverable],

      ["Details", details],

      ["Recommendations", recommendations],

      ["Next Steps", nextSteps]

    ].filter(([, value]) => String(value || "").trim());

    const chips = [

      status ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(134,239,172,.38);background:rgba(20,83,45,.22);color:#bbf7d0;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(status)}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticType)}</span>`,

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(251,191,36,.34);background:rgba(120,53,15,.18);color:#fde68a;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticPriority)}</span>`

    ].filter(Boolean).join("");

'''

if old not in text:

    raise SystemExit("Target block not found. No changes applied.")

text = text.replace(old, new, 1)

path.write_text(text)

