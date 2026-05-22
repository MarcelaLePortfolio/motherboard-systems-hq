
import fs from "fs";

const payloadPath = process.argv[2];

if (!payloadPath) {

  console.error("Missing payload path.");

  process.exit(1);

}

const raw = fs.readFileSync(payloadPath, "utf8");

const payload = JSON.parse(raw);

const requiredTopLevel = [

  "schema_version",

  "artifact_type",

  "scene",

  "layout",

  "layout_tokens",

  "style_tokens",

  "nodes",

  "text",

  "validation"

];

for (const key of requiredTopLevel) {

  if (!(key in payload)) {

    console.error(`Missing required field: ${key}`);

    process.exit(1);

  }

}

if (!Array.isArray(payload.nodes)) {

  console.error("nodes must be an array");

  process.exit(1);

}

if (

  !payload.style_tokens ||

  typeof payload.style_tokens !== "object" ||

  Array.isArray(payload.style_tokens)

) {

  console.error("style_tokens must be an object");

  process.exit(1);

}

if (

  !payload.layout_tokens ||

  typeof payload.layout_tokens !== "object" ||

  Array.isArray(payload.layout_tokens)

) {

  console.error("layout_tokens must be an object");

  process.exit(1);

}

for (const node of payload.nodes) {

  const requiredNodeFields = ["id", "type", "content"];

  for (const field of requiredNodeFields) {

    if (!(field in node)) {

      console.error(`Node missing required field: ${field}`);

      process.exit(1);

    }

  }

  if (

    "style_token" in node &&

    !(node.style_token in payload.style_tokens)

  ) {

    console.error(`Unknown style_token on node ${node.id}: ${node.style_token}`);

    process.exit(1);

  }

  if (

    "layout_token" in node &&

    !(node.layout_token in payload.layout_tokens)

  ) {

    console.error(`Unknown layout_token on node ${node.id}: ${node.layout_token}`);

    process.exit(1);

  }

}

if (payload.validation.deterministic !== true) {

  console.error("Payload must be deterministic.");

  process.exit(1);

}

if (payload.validation.sandbox_only !== true) {

  console.error("Payload must remain sandbox_only.");

  process.exit(1);

}

console.log("VALIDATION PASS");

console.log(`Validated payload: ${payloadPath}`);

