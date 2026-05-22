
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const inputPath = process.argv[2];

const outputPath =

  process.argv[3] ||

  "scripts/render-native/output/rendered-sandbox.html";

if (!inputPath) {

  console.error("Missing payload path.");

  process.exit(1);

}

const payload = JSON.parse(readFileSync(inputPath, "utf8"));

if (!payload.validation?.sandbox_only) {

  console.error("Refusing to render non-sandbox payload.");

  process.exit(1);

}

const nodesById = new Map(payload.nodes.map((node) => [node.id, node]));

function escapeHtml(value) {

  return String(value)

    .replaceAll("&", "&amp;")

    .replaceAll("<", "&lt;")

    .replaceAll(">", "&gt;")

    .replaceAll('"', "&quot;")

    .replaceAll("'", "&#039;");

}

function renderNode(nodeId) {

  const node = nodesById.get(nodeId);

  if (!node) {

    return "";

  }

  const attributes = [

    `data-node-id="${escapeHtml(node.id)}"`,

    `data-style-token="${escapeHtml(node.style_token)}"`,

    `data-layout-token="${escapeHtml(node.layout_token)}"`

  ].join(" ");

  if (node.type === "container") {

    const children = node.content?.children || [];

    return `

      <div class="rn-node rn-container-node rn-style-${escapeHtml(node.style_token)} rn-layout-${escapeHtml(node.layout_token)}" ${attributes}>

        ${children.map(renderNode).join("\n")}

      </div>

    `;

  }

  if (node.type === "text") {

    return `

      <div class="rn-node rn-text-node rn-style-${escapeHtml(node.style_token)} rn-layout-${escapeHtml(node.layout_token)}" ${attributes}>

        ${escapeHtml(node.content?.value || "")}

      </div>

    `;

  }

  return `

    <div class="rn-node rn-unknown-node" ${attributes}>

      Unsupported node type: ${escapeHtml(node.type)}

    </div>

  `;

}

const rendered = renderNode(payload.scene.root);

const html = `<!DOCTYPE html>

<html>

<head>

  <meta charset="UTF-8" />

  <title>Render-Native Sandbox Output</title>

  <style>

    :root {

      color-scheme: dark;

      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;

      background: #0f1117;

      color: #f4f7fb;

    }

    body {

      margin: 0;

      min-height: 100vh;

      display: grid;

      place-items: center;

      background:

        radial-gradient(circle at top left, rgba(255, 46, 169, 0.16), transparent 32rem),

        linear-gradient(135deg, #0f1117 0%, #171a23 100%);

    }

    #sandbox-render-root {

      width: min(720px, calc(100vw - 48px));

    }

    .rn-node {

      box-sizing: border-box;

    }

    .rn-container-node {

      border: 1px solid rgba(255, 255, 255, 0.12);

      border-radius: 24px;

      box-shadow: 0 24px 80px rgba(0, 0, 0, 0.32);

      backdrop-filter: blur(16px);

    }

    .rn-layout-stack {

      display: flex;

      flex-direction: column;

      gap: 16px;

      align-items: stretch;

      padding: 28px;

    }

    .rn-layout-card {

      border-radius: 18px;

      padding: 18px 20px;

      background: rgba(255, 255, 255, 0.06);

    }

    .rn-layout-badge {

      align-self: flex-start;

      border-radius: 999px;

      padding: 8px 14px;

      font-size: 0.78rem;

      font-weight: 800;

      letter-spacing: 0.12em;

      text-transform: uppercase;

    }

    .rn-style-background {

      background: rgba(22, 25, 34, 0.86);

    }

    .rn-style-text {

      font-size: clamp(1.8rem, 4vw, 3rem);

      line-height: 1.05;

      font-weight: 850;

    }

    .rn-style-accent {

      color: #ff8bd3;

      font-size: 1.05rem;

      line-height: 1.6;

    }

    .rn-style-evidence {

      color: #a8d8ff;

      font-size: 0.95rem;

      line-height: 1.5;

    }

    .rn-style-warning {

      color: #ffd28a;

      font-size: 0.95rem;

      line-height: 1.5;

    }

    .rn-style-status-pass {

      color: #102217;

      background: #8ff0b0;

    }

  </style>

</head>

<body>

  <main id="sandbox-render-root" data-schema-version="${escapeHtml(payload.schema_version)}" data-scene-pattern="${escapeHtml(payload.scene.pattern || "unknown")}">

    ${rendered}

  </main>

</body>

</html>

`;

mkdirSync("scripts/render-native/output", { recursive: true });

writeFileSync(outputPath, html);

console.log("SANDBOX RENDER PASS");

console.log(`Rendered sandbox HTML written to: ${outputPath}`);

