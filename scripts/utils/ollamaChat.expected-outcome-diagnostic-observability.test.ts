import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "expectedOutcome fidelity failure exposes bounded diagnostic values without relaxing validation",
  () => {
    assert.match(
      source,
      /\[Ollama expectedOutcome fidelity diagnostic\]/,
    );
    assert.match(
      source,
      /currentRequest:\s*concreteOperationMessage/,
    );
    assert.match(
      source,
      /modelAuthoredExpectedOutcome:\s*packageSemantics\.expectedOutcome/,
    );
    assert.match(
      source,
      /Ollama response failed current-request Package Semantics fidelity for expectedOutcome\./,
    );
  },
);
