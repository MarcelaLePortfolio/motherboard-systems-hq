import { readFileSync } from "node:fs";

const source = readFileSync(
  "src/cognition/situationSummaryComposer.ts",
  "utf8",
);

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

assert(
  source.includes('from "./confidence"'),
  "Expected situation summary composer to import confidence module.",
);

assert(
  source.includes("function buildSituationOperationalConfidence("),
  "Expected operational confidence builder helper in situation summary composer.",
);

assert(
  source.includes("operationalConfidence?: OperationalConfidence;"),
  "Expected SituationSummary contract to expose operationalConfidence.",
);

assert(
  source.includes("operationalConfidence: buildSituationOperationalConfidence({"),
  "Expected composed situation summary to include operationalConfidence.",
);

assert(
  source.includes("governanceCognitionState"),
  "Expected governance cognition state to remain part of situation summary integration.",
);

console.log("phase99.3 situation summary confidence smoke: PASS");
