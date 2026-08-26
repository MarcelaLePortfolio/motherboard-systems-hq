import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const ielSource = fs.readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

const workflowSource = fs.readFileSync(
  "server/matilda-chat-workflow.ts",
  "utf8",
);

const synthesisSource = fs.readFileSync(
  "db/matilda-draft-synthesis-runtime.ts",
  "utf8",
);

test(
  "IEL accepts typed Package Semantics artifact",
  () => {
    assert.match(
      ielSource,
      /package_semantics\?:\s*MatildaPackageSemanticsArtifact \| null;/,
    );

    assert.match(
      ielSource,
      /package_semantics_json TEXT/,
    );
  },
);

test(
  "IEL owns Package Semantics validation and JSON persistence",
  () => {
    assert.match(
      ielSource,
      /package_semantics_json:\s*[\s\S]*input\.package_semantics === null[\s\S]*input\.package_semantics === undefined[\s\S]*\? null[\s\S]*JSON\.stringify\([\s\S]*validateMatildaPackageSemanticsArtifact\([\s\S]*input\.package_semantics/s,
    );

    assert.match(
      ielSource,
      /@package_semantics_json/,
    );
  },
);

test(
  "IEL reconstructs persisted Package Semantics fail closed",
  () => {
    assert.match(
      ielSource,
      /function reconstructPackageSemantics\(/,
    );

    assert.match(
      ielSource,
      /Matilda IEL contains malformed package semantics JSON/,
    );

    assert.match(
      ielSource,
      /validateMatildaPackageSemanticsArtifact\(\s*parsed,\s*"Matilda IEL contains"/s,
    );

    assert.match(
      ielSource,
      /packageSemantics:\s*reconstructPackageSemantics\(\s*row\.package_semantics_json/s,
    );
  },
);

test(
  "workflow directly transports Matilda-authored Package Semantics through the existing IEL write",
  () => {
    assert.match(
      workflowSource,
      /package_semantics:\s*[\r\n ]*ollamaResult\.packageSemantics/,
    );

    const writes =
      workflowSource.match(
        /createInterpretationEvidenceLedgerEntry\(/g,
      ) || [];

    assert.equal(writes.length, 1);
  },
);

test(
  "legacy unresolved_questions workflow write remains null",
  () => {
    assert.match(
      workflowSource,
      /unresolved_questions:\s*null/,
    );
  },
);

test(
  "Living Draft selects one newest eligible non-null Package Semantics artifact atomically",
  () => {
    assert.match(
      synthesisSource,
      /const selectedPackageSemantics = evidence[\s\S]*\.find\(\(entry: any\) => entry\.packageSemantics !== null\)[\s\S]*\?\.packageSemantics \?\? null;/,
    );

    assert.doesNotMatch(
      synthesisSource,
      /packageSemantics.*map\(/,
    );
  },
);

test(
  "Living Draft structured fields are sourced from the selected atomic Package Semantics artifact",
  () => {
    const mappings = [
      ["proposed_work", "proposedWork"],
      ["proposed_artifacts", "proposedArtifacts"],
      ["in_scope", "inScope"],
      ["out_of_scope", "outOfScope"],
      ["constraints", "constraints"],
      ["expected_outcome", "expectedOutcome"],
      ["unresolved_questions", "unresolvedQuestions"],
    ] as const;

    for (const [draftField, semanticField] of mappings) {
      assert.match(
        synthesisSource,
        new RegExp(
          `${draftField}:\\s*[\\s\\S]*selectedPackageSemantics\\?\\.${semanticField} \\?\\? null`,
        ),
      );
    }
  },
);

test(
  "Living Draft current interpretation continues to derive from Matilda observations",
  () => {
    assert.match(
      synthesisSource,
      /\.map\(\(entry: any\) => entry\.matilda_observation\)/,
    );

    assert.match(
      synthesisSource,
      /current_interpretation:\s*interpretation/,
    );
  },
);

test(
  "generic structured Living Draft defaults are absent",
  () => {
    for (const genericCopy of [
      "Continue synthesizing interpretation evidence into a reviewable Living Draft Package.",
      "A continuously improving Living Draft Package.",
      "Interpretation synthesis only.",
      "Canonical Package creation, Delegation, Validation, Envelope creation, Routing, Assignment, Cade execution.",
      "Remain non-authoritative until explicit operator approval.",
    ]) {
      assert.doesNotMatch(
        synthesisSource,
        new RegExp(
          genericCopy.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        ),
      );
    }
  },
);
