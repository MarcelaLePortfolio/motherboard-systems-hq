import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

test("exact-ID IEL reader is bounded by identity, project, and conversation", () => {
  const repositoryRoot = process.cwd();
  const temporaryRoot = mkdtempSync(
    path.join(tmpdir(), "matilda-exact-id-iel-test-"),
  );

  mkdirSync(path.join(temporaryRoot, "db"));

  try {
    process.chdir(temporaryRoot);

    const runtime = require(
      path.join(
        repositoryRoot,
        "db",
        "matilda-interpretation-runtime.ts",
      ),
    );

    const create = (
      entryId: string,
      projectId: string,
      conversationId: string,
    ) =>
      runtime.createInterpretationEvidenceLedgerEntry({
        entry_id: entryId,
        actor: "matilda",
        project_id: projectId,
        conversation_id: conversationId,
        interpretation_event: `Interpretation ${entryId}`,
        minimum_sufficient_context: "Bounded exact-ID reader test.",
        supporting_raw_evidence: `Evidence ${entryId}`,
        matilda_observation: `Observation ${entryId}`,
      });

    create("iel-target-one", "hq", "conversation-target");
    create("iel-target-two", "hq", "conversation-target");
    create("iel-foreign-conversation", "hq", "conversation-other");
    create("iel-foreign-project", "other-project", "conversation-target");

    const read =
      runtime.readInterpretationEvidenceLedgerEntriesByIds;

    assert.deepEqual(
      read([], {
        projectId: "hq",
        conversationId: "conversation-target",
      }),
      [],
    );

    const exact = read(
      [
        "iel-target-one",
        "iel-target-two",
        "iel-target-one",
        "iel-missing",
        "iel-foreign-conversation",
        "iel-foreign-project",
      ],
      {
        projectId: "hq",
        conversationId: "conversation-target",
      },
    );

    assert.deepEqual(
      new Set(exact.map((entry: { entry_id: string }) => entry.entry_id)),
      new Set(["iel-target-one", "iel-target-two"]),
    );

    assert.equal(exact.length, 2);

    assert.equal(
      exact.some(
        (entry: { entry_id: string }) =>
          entry.entry_id === "iel-foreign-conversation",
      ),
      false,
    );

    assert.equal(
      exact.some(
        (entry: { entry_id: string }) =>
          entry.entry_id === "iel-foreign-project",
      ),
      false,
    );

    assert.equal(
      exact.some(
        (entry: { entry_id: string }) =>
          entry.entry_id === "iel-missing",
      ),
      false,
    );

    assert.throws(
      () =>
        read(["iel-target-one"], {
          projectId: "",
          conversationId: "conversation-target",
        }),
      /projectId is required/,
    );

    assert.throws(
      () =>
        read(["iel-target-one"], {
          projectId: "hq",
          conversationId: "",
        }),
      /conversationId is required/,
    );
  } finally {
    process.chdir(repositoryRoot);
    rmSync(temporaryRoot, {
      recursive: true,
      force: true,
    });
  }
});
