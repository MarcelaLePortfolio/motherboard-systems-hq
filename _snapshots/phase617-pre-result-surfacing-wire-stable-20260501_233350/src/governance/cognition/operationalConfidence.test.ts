import { synthesizeOperationalConfidence } from "./operationalConfidence.synthesizer";

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(message);
  }
}

const high = synthesizeOperationalConfidence([
  { source: "governance", confidence: "HIGH" },
]);

assert(high.level === "HIGH", "Expected HIGH confidence");

const mixed = synthesizeOperationalConfidence([
  { source: "governance", confidence: "HIGH" },
  { source: "signals", confidence: "MEDIUM" },
]);

assert(mixed.level === "MEDIUM", "Expected MEDIUM confidence");

const low = synthesizeOperationalConfidence([
  { source: "governance", confidence: "LOW" },
  { source: "signals", confidence: "HIGH" },
]);

assert(low.level === "LOW", "Expected LOW confidence");

console.log("phase 99.2 operational confidence deterministic check passed");
