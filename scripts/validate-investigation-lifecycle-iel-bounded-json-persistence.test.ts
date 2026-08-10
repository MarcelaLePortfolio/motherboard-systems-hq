import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

test(
  "IEL schema carries additive nullable Investigation Lifecycle JSON",
  () => {
    assert.match(
      source,
      /investigation_lifecycle_json TEXT/,
    );
  },
);

test(
  "IEL input accepts nullable bounded lifecycle JSON",
  () => {
    assert.match(
      source,
      /investigation_lifecycle_json\?: string \| null;/,
    );
  },
);

test(
  "IEL migration adds lifecycle JSON without backfill",
  () => {
    assert.match(
      source,
      /column\.name === "investigation_lifecycle_json"/,
    );

    assert.match(
      source,
      /ALTER TABLE matilda_interpretation_evidence_ledger[\s\S]*ADD COLUMN investigation_lifecycle_json TEXT/,
    );

    assert.doesNotMatch(
      source,
      /investigation_lifecycle_json\s*=/,
    );
  },
);

test(
  "IEL INSERT persists nullable lifecycle JSON",
  () => {
    assert.match(
      source,
      /INSERT INTO matilda_interpretation_evidence_ledger[\s\S]*investigation_lifecycle_json[\s\S]*@investigation_lifecycle_json/,
    );

    assert.match(
      source,
      /investigation_lifecycle_json:\s*[\r\n ]*input\.investigation_lifecycle_json \?\? null/,
    );
  },
);

test(
  "lifecycle persistence remains owned by IEL runtime",
  () => {
    const workflow = fs.readFileSync(
      "server/matilda-chat-workflow.ts",
      "utf8",
    );

    assert.doesNotMatch(
      workflow,
      /investigation_lifecycle_json/,
    );
  },
);
