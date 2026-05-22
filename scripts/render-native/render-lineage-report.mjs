
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const reportPath =

  process.argv[2] ||

  "scripts/render-native/reports/lineage-report.json";

const outputPath =

  process.argv[3] ||

  "scripts/render-native/output/semantic-lineage-report.html";

const report = JSON.parse(readFileSync(reportPath, "utf8"));

function escapeHtml(value) {

  return String(value)

    .replaceAll("&", "&amp;")

    .replaceAll("<", "&lt;")

    .replaceAll(">", "&gt;")

    .replaceAll('"', "&quot;")

    .replaceAll("'", "&#039;");

}

const lineageCards = report.node_lineage.map((node) => `

  <section class="lineage-card">

    <div class="lineage-header">

      <div class="node-id">${escapeHtml(node.id)}</div>

      <div class="node-type">${escapeHtml(node.type)}</div>

    </div>

    <div class="lineage-row">

      <span class="label">semantic role</span>

      <strong>${escapeHtml(node.semantic_role || "none")}</strong>

    </div>

    <div class="lineage-row">

      <span class="label">generated from</span>

      <strong>${escapeHtml(node.generated_from || "unknown")}</strong>

    </div>

    <div class="lineage-row">

      <span class="label">emitted by</span>

      <strong>${escapeHtml(node.emitted_by || "unknown")}</strong>

    </div>

    <div class="lineage-row">

      <span class="label">snapshot source</span>

      <strong>${escapeHtml(node.snapshot_source || "unknown")}</strong>

    </div>

    <div class="lineage-row">

      <span class="label">lineage scope</span>

      <strong>${escapeHtml(node.lineage_scope || "unknown")}</strong>

    </div>

  </section>

`).join("\n");

const html = `<!DOCTYPE html>

<html>

<head>

  <meta charset="UTF-8" />

  <title>Semantic Lineage Report</title>

  <style>

    :root {

      color-scheme: dark;

      font-family: Inter, system-ui, sans-serif;

    }

    body {

      margin: 0;

      padding: 48px;

      background:

        radial-gradient(circle at top left, rgba(255, 46, 169, 0.14), transparent 28rem),

        linear-gradient(135deg, #0f1117 0%, #171a23 100%);

      color: #f4f7fb;

    }

    h1 {

      font-size: clamp(2.5rem, 5vw, 4rem);

      font-weight: 900;

      line-height: 1;

      margin-bottom: 12px;

    }

    .subtitle {

      color: #ff8bd3;

      margin-bottom: 42px;

      font-size: 1.05rem;

    }

    .grid {

      display: grid;

      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));

      gap: 18px;

    }

    .lineage-card {

      background: rgba(255,255,255,0.05);

      border: 1px solid rgba(255,255,255,0.08);

      border-radius: 24px;

      padding: 22px;

      backdrop-filter: blur(12px);

    }

    .lineage-header {

      display: flex;

      justify-content: space-between;

      align-items: center;

      gap: 12px;

      margin-bottom: 22px;

    }

    .node-id {

      font-weight: 900;

      font-size: 1rem;

    }

    .node-type {

      background: #8ff0b0;

      color: #102217;

      border-radius: 999px;

      padding: 6px 10px;

      font-size: 0.74rem;

      text-transform: uppercase;

      font-weight: 800;

    }

    .lineage-row {

      margin-top: 12px;

      display: flex;

      flex-direction: column;

      gap: 4px;

    }

    .label {

      color: #9aa7bb;

      font-size: 0.76rem;

      text-transform: uppercase;

      letter-spacing: 0.08em;

    }

  </style>

</head>

<body>

  <h1>Semantic Lineage</h1>

  <div class="subtitle">

    Deterministic ancestry inspection for semantic artifact objects.

  </div>

  <div class="grid">

    ${lineageCards}

  </div>

</body>

</html>

`;

mkdirSync("scripts/render-native/output", { recursive: true });

writeFileSync(outputPath, html);

console.log("LINEAGE REPORT RENDER PASS");

console.log(`Semantic lineage report written to: ${outputPath}`);

