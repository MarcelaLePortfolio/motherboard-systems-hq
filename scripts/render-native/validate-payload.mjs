
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

for (const node of payload.nodes) {

  const requiredNodeFields = ["id", "type", "content"];

  for (const field of requiredNodeFields) {

    if (!(field in node)) {

      console.error(`Node missing required field: ${field}`);

      process.exit(1);

    }

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

