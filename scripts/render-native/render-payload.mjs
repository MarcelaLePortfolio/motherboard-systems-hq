
import fs from "fs";

const payloadPath = process.argv[2];

if (!payloadPath) {

  console.error("Missing payload path.");

  process.exit(1);

}

const raw = fs.readFileSync(payloadPath, "utf8");

const payload = JSON.parse(raw);

const nodeMap = new Map();

for (const node of payload.nodes) {

  nodeMap.set(node.id, node);

}

function tokenAttribute(node) {

  if (!node.style_token) {

    return "";

  }

  return ` data-style-token="${node.style_token}"`;

}

function renderNode(nodeId) {

  const node = nodeMap.get(nodeId);

  if (!node) {

    return `<div data-missing-node="${nodeId}"></div>`;

  }

  if (node.type === "text") {

    return `

      <div class="text-node" data-node-id="${node.id}"${tokenAttribute(node)}>

        ${node.content.value}

      </div>

    `;

  }

  if (node.type === "container") {

    const children = node.content.children || [];

    return `

      <div class="container-node" data-node-id="${node.id}"${tokenAttribute(node)}>

        ${children.map(renderNode).join("\n")}

      </div>

    `;

  }

  return `

    <div class="unknown-node" data-node-id="${node.id}"${tokenAttribute(node)}>

      UNKNOWN NODE TYPE

    </div>

  `;

}

const html = `

<!DOCTYPE html>

<html>

<head>

  <meta charset="UTF-8" />

  <title>Render-Native Sandbox Output</title>

</head>

<body>

  <div id="sandbox-render-root">

    ${renderNode(payload.scene.root)}

  </div>

</body>

</html>

`;

const outputPath = "scripts/render-native/output/rendered-sandbox.html";

fs.writeFileSync(outputPath, html);

console.log("SANDBOX RENDER PASS");

console.log(`Output written to: ${outputPath}`);

