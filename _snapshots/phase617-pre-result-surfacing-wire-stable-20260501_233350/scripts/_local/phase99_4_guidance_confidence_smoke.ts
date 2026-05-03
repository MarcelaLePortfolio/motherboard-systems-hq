import { readFileSync } from "node:fs";

const source = readFileSync(
  "src/cognition/operatorGuidanceConfidence.ts",
  "utf8",
);

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

assert(
  source.includes('import type { OperationalConfidence } from "./confidence";'),
  "Expected operatorGuidanceConfidence.ts to import OperationalConfidence.",
);

assert(
  source.includes("operationalConfidence?: OperationalConfidence;"),
  "Expected OperatorGuidanceConfidenceInput to expose operationalConfidence.",
);

assert(
  source.includes("export function mapOperationalConfidenceToGuidanceModifier("),
  "Expected operational confidence guidance modifier mapper to exist.",
);

assert(
  source.includes('if (confidence.level === "HIGH") return 1;'),
  "Expected HIGH operational confidence mapping to guidance modifier 1.",
);

assert(
  source.includes('if (confidence.level === "MEDIUM") return 0;'),
  "Expected MEDIUM operational confidence mapping to guidance modifier 0.",
);

assert(
  source.includes('if (confidence.level === "LOW") return -1;'),
  "Expected LOW operational confidence mapping to guidance modifier -1.",
);

console.log("phase99.4 guidance confidence smoke: PASS");
