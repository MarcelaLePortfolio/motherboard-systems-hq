
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const payloadPath =

  process.argv[2] ||

  "scripts/render-native/generated/compiled-semantic-payload.json";

const reportPath =

  process.argv[3] ||

  "scripts/render-native/output/graph-structure-report.html";

const payload = JSON.parse(readFileSync(payloadPath, "utf8"));

const nodes = payload.nodes || [];

function escapeHtml(value) {

  return String(value)

    .replaceAll("&", "&amp;")

    .replaceAll("<", "&lt;")

    .replaceAll(">", "&gt;")

    .replaceAll('"', "&quot;")

    .replaceAll("'", "&#039;");

}

const relationRows = nodes.flatMap((node) =>

  (node.relations || []).map((relation) => `

    <tr>

      <td>${escapeHtml(node.id)}</td>

      <td>${escapeHtml(relation.type)}</td>

      <td>${escapeHtml(relation.target)}</td>

    </tr>

  `)

);

const nodeCards = nodes.map((node) => `

  <section class="node-card">

    <div class="node-header">

      <div class="node-id">${escapeHtml(node.id)}</div>

      <div class="node-type">${escapeHtml(node.type)}</div>

    </div>

    <div class="node-meta">

      semantic_role:

      <strong>${escapeHtml(node.meta?.semantic_role || "none")}</strong>

    </div>

    <div class="node-relations">

      relations:

      <strong>${(node.relations || []).length}</strong>

    </div>

  </section>

`);

const html = `<!DOCTYPE html>

<html>

<head>

  <meta charset="UTF-8" />

  <title>Semantic Graph Structure Report</title>

  <style>

    :root {

      color-scheme: dark;

      font-family: Inter, system-ui, sans-serif;

      background: #0f1117;

      color: #f4f7fb;

    }

    body {

      margin: 0;

      padding: 48px;

      background:

        radial-gradient(circle at top left, rgba(255, 46, 169, 0.14), transparent 28rem),

        linear-gradient(135deg, #0f1117 0%, #171a23 100%);

    }

    h1 {

      font-size: clamp(2.5rem, 5vw, 4rem);

      line-height: 1;

      margin-bottom: 12px;

      font-weight: 900;

    }

    .subtitle {

      color: #ff8bd3;

      margin-bottom: 40px;

      font-size: 1.05rem;

    }

    .grid {

      display: grid;

      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));

      gap: 18px;

      margin-bottom: 48px;

    }

    .node-card {

      background: rgba(255,255,255,0.05);

      border: 1px solid rgba(255,255,255,0.1);

      border-radius: 22px;

      padding: 20px;

      backdrop-filter: blur(12px);

    }

    .node-header {

      display: flex;

      justify-content: space-between;

      gap: 12px;

      margin-bottom: 18px;

      align-items: center;

    }

    .node-id {

      font-weight: 800;

      font-size: 1rem;

    }

    .node-type {

      background: #8ff0b0;

      color: #102217;

      border-radius: 999px;

      padding: 6px 10px;

      font-size: 0.75rem;

      font-weight: 800;

      text-transform: uppercase;

    }

    .node-meta,

    .node-relations {

      color: #c8d0dc;

      margin-top: 10px;

    }

    table {

      width: 100%;

      border-collapse: collapse;

      background: rgba(255,255,255,0.05);

      border-radius: 20px;

      overflow: hidden;

    }

    th,

    td {

      padding: 14px 16px;

      text-align: left;

      border-bottom: 1px solid rgba(255,255,255,0.08);

    }

    th {

      color: #ff8bd3;

      font-size: 0.82rem;

      text-transform: uppercase;

      letter-spacing: 0.08em;

    }

  </style>

</head>

<body>

  <h1>Semantic Graph Structure</h1>

  <div class="subtitle">

    Deterministic semantic topology inspection report.

  </div>

  <div class="grid">

    ${nodeCards.join("\n")}

  </div>

  <table>

    <thead>

      <tr>

        <th>Source</th>

        <th>Relation</th>

        <th>Target</th>

      </tr>

    </thead>

    <tbody>

      ${relationRows.join("\n")}

    </tbody>

  </table>

</body>

</html>

`;

mkdirSync("scripts/render-native/output", { recursive: true });

writeFileSync(reportPath, html);

console.log("GRAPH REPORT RENDER PASS");

console.log(`Graph report written to: ${reportPath}`);

