import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const ollamaSource = readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

const ielSource = readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

test("shared bounded lifecycle validator exists", () => {
  assert.match(
    ollamaSource,
    /export function validateMatildaInvestigationLifecycleArtifact/,
  );
});

test("Ollama parser consumes shared lifecycle validator", () => {
  assert.match(
    ollamaSource,
    /validateMatildaInvestigationLifecycleArtifact\(\s*parsed\.investigationLifecycle/,
  );
});

test("IEL existing reader projects lifecycle JSON", () => {
  const reader = ielSource.slice(
    ielSource.indexOf(
      "export function listInterpretationEvidenceLedgerEntries",
    ),
  );

  assert.match(
    reader,
    /investigation_lifecycle_json/,
  );
});

test("IEL read model exposes typed lifecycle artifact", () => {
  assert.match(
    ielSource,
    /investigationLifecycle:\s*MatildaInvestigationLifecycleArtifact \| null/,
  );
});

test("IEL owns deterministic lifecycle JSON parsing", () => {
  assert.match(
    ielSource,
    /JSON\.parse\(value\)/,
  );

  assert.match(
    ielSource,
    /validateMatildaInvestigationLifecycleArtifact\(/,
  );
});

test("SQL null reconstructs as semantic null", () => {
  assert.match(
    ielSource,
    /if \(value === null\) \{\s*return null;/,
  );
});

test("malformed persisted JSON fails closed", () => {
  assert.match(
    ielSource,
    /Matilda IEL contains malformed investigation lifecycle JSON/,
  );
});

test("no lifecycle semantics are inferred from other IEL fields", () => {
  const reconstructionStart = ielSource.indexOf(
    "function reconstructInvestigationLifecycle",
  );

  const reconstructionEnd = ielSource.indexOf(
    "export function listInterpretationEvidenceLedgerEntries",
    reconstructionStart,
  );

  const reconstruction = ielSource.slice(
    reconstructionStart,
    reconstructionEnd,
  );

  assert.doesNotMatch(
    reconstruction,
    /durableInterpretation|matilda_observation|supersession_status|conversation_id|created_at/,
  );
});
