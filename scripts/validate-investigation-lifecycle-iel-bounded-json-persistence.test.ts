import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

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
  "IEL input accepts nullable bounded typed lifecycle artifact",
  () => {
    assert.match(
      source,
      /investigation_lifecycle\?:\s*MatildaInvestigationLifecycleArtifact \| null;/,
    );

    assert.doesNotMatch(
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
      /ALTER TABLE matilda_interpretation_evidence_ledger[\s\S]*ADD COLUMN investigation_lifecycle_json TEXT;/,
    );

    assert.doesNotMatch(
      source,
      /UPDATE matilda_interpretation_evidence_ledger[\s\S]*investigation_lifecycle_json\s*=/,
    );
  },
);

test(
  "IEL deterministically serializes nullable lifecycle artifact",
  () => {
    assert.match(
      source,
      /investigation_lifecycle_json:\s*[\s\S]*input\.investigation_lifecycle === null[\s\S]*input\.investigation_lifecycle === undefined[\s\S]*\? null[\s\S]*JSON\.stringify\([\s\S]*input\.investigation_lifecycle/,
    );
  },
);

test(
  "lifecycle persistence remains owned by IEL runtime",
  () => {
    assert.match(
      source,
      /@investigation_lifecycle_json/,
    );

    assert.match(
      source,
      /JSON\.stringify\([\s\S]*input\.investigation_lifecycle/,
    );
  },
);
