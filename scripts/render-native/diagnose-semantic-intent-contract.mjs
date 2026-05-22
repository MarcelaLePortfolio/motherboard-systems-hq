
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

const compilerLines = compilerSource.split("\n");

const relevantCompilerLines = compilerLines

  .map((line, index) => ({ line_number: index + 1, text: line }))

  .filter(({ text }) =>

    /semantic|intent|artifact|payload|required|missing|field|validate|schema/i.test(text)

  );

const quotedTokens = [

  ...new Set(

    [...compilerSource.matchAll(/["'`]([a-zA-Z0-9_-]+)["'`]/g)]

      .map((match) => match[1])

      .filter((token) =>

        /schema|intent|artifact|payload|scene|component|title|summary|type|id|layout|style|theme|accent|headline|subheadline/i.test(token)

      )

  )

];

const report = {

  schema_version: "phase736.semantic-intent-contract-diagnostic.v2",

  corridor: "read-only-diagnostic",

  compiler_path: compilerPath,

  semantic_input_path: semanticInputPath,

  present_fields: Object.keys(semanticInput),

  quoted_contract_tokens_detected: quotedTokens,

  relevant_compiler_lines: relevantCompilerLines,

  diagnostic_note: "This script reads compiler and semantic input only. It does not mutate runtime Preview or renderer state."

};

console.log(JSON.stringify(report, null, 2));

