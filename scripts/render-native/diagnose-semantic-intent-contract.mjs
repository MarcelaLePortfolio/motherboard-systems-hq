
import { readFileSync, existsSync } from "node:fs";

const compilerPath = "scripts/render-native/compile-semantic-intent.mjs";

const semanticInputPath = "sandbox/semantic-inputs/sample-semantic-intent.json";

if (!existsSync(compilerPath)) {

  console.error(`Missing compiler: ${compilerPath}`);

  process.exit(1);

}

if (!existsSync(semanticInputPath)) {

  console.error(`Missing semantic input: ${semanticInputPath}`);

  process.exit(1);

}

const compilerSource = readFileSync(compilerPath, "utf8");

const semanticInput = JSON.parse(readFileSync(semanticInputPath, "utf8"));

const missingFieldMatches = [...compilerSource.matchAll(/Missing semantic intent field:\s*\$\{field\}|requiredFields\s*=\s*\[([\s\S]*?)\]/g)];

const requiredFieldsBlockMatch = compilerSource.match(/requiredFields\s*=\s*\[([\s\S]*?)\]/);

const requiredFields = requiredFieldsBlockMatch

  ? [...requiredFieldsBlockMatch[1].matchAll(/["'`]([^"'`]+)["'`]/g)].map((match) => match[1])

  : [];

const report = {

  schema_version: "phase736.semantic-intent-contract-diagnostic.v1",

  corridor: "read-only-diagnostic",

  compiler_path: compilerPath,

  semantic_input_path: semanticInputPath,

  required_fields_detected: requiredFields,

  present_fields: Object.keys(semanticInput),

  missing_fields: requiredFields.filter((field) => !(field in semanticInput)),

  compiler_mentions_missing_field_message: compilerSource.includes("Missing semantic intent field"),

  diagnostic_note: "This script reads compiler and semantic input only. It does not mutate runtime Preview or renderer state."

};

console.log(JSON.stringify(report, null, 2));

if (report.missing_fields.length > 0) {

  process.exit(1);

}

