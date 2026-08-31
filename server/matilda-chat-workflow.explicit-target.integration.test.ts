import assert from "node:assert/strict";
import { createServer, type Server } from "node:http";
import {
  copyFileSync,
  mkdirSync,
  mkdtempSync,
  rmSync,
  symlinkSync,
} from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import Database from "better-sqlite3";

const repositoryRoot = process.cwd();

function listen(server: Server): Promise<number> {
  return new Promise((resolve, reject) => {
    server.once("error", reject);

    server.listen(0, "127.0.0.1", () => {
      const address = server.address();

      if (!address || typeof address === "string") {
        reject(
          new Error(
            "Local Ollama stub did not expose a TCP port.",
          ),
        );
        return;
      }

      resolve(address.port);
    });
  });
}

function closeServer(server: Server): Promise<void> {
  return new Promise((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });
}

test(
  "real shared workflow persists a revision to an explicit non-active conversation without switching active context",
  async () => {
    const temporaryRoot = mkdtempSync(
      path.join(
        tmpdir(),
        "matilda-request-changes-workflow-",
      ),
    );

    const temporaryDbDirectory =
      path.join(temporaryRoot, "db");

    const temporaryServerDirectory =
      path.join(temporaryRoot, "server");

    mkdirSync(temporaryDbDirectory, {
      recursive: true,
    });

    mkdirSync(temporaryServerDirectory, {
      recursive: true,
    });

    /*
     * project-registry.mjs is dynamically imported from CWD by
     * the production workflow. Copy the standalone registry module
     * into the isolated fixture and expose the repository's installed
     * packages through a fixture-local node_modules symlink so normal
     * ESM package resolution remains available without using production
     * persistence.
     */
    copyFileSync(
      path.join(
        repositoryRoot,
        "server",
        "project-registry.mjs",
      ),
      path.join(
        temporaryServerDirectory,
        "project-registry.mjs",
      ),
    );

    symlinkSync(
      path.join(repositoryRoot, "node_modules"),
      path.join(temporaryRoot, "node_modules"),
      "dir",
    );

    const stub = createServer(
      (request, response) => {
        if (
          request.method !== "POST"
          || request.url !== "/api/generate"
        ) {
          response.statusCode = 404;
          response.end();
          return;
        }

        let body = "";

        request.setEncoding("utf8");

        request.on("data", (chunk) => {
          body += chunk;
        });

        request.on("end", () => {
          assert.ok(body.length > 0);

          const structuredResponse = {
            reply:
              "I incorporated the requested revision.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [],
            evidence: null,
            investigationLifecycle: null,
            packageSemantics: {
              expectedOutcome:
                "Preserve the reviewed intent with the requested correction.",
              proposedWork:
                "Revise the reviewed interpretation using the supplied feedback.",
              proposedArtifacts: null,
              inScope:
                "The requested correction to the reviewed interpretation.",
              outOfScope:
                "Canonical approval and all downstream execution authority.",
              constraints:
                "Remain non-authoritative until separately approved.",
              unresolvedQuestions: null,
            },
            durableInterpretation:
              "The reviewed intent should incorporate the requested correction while remaining non-authoritative.",
          };

          response.writeHead(200, {
            "content-type": "application/json",
          });

          response.end(
            JSON.stringify({
              response:
                JSON.stringify(
                  structuredResponse,
                ),
              done: true,
            }),
          );
        });
      },
    );

    let database:
      Database.Database | null = null;

    try {
      const port = await listen(stub);

      process.env.OLLAMA_BASE_URL =
        `http://127.0.0.1:${port}`;

      process.chdir(temporaryRoot);

      const conversationRuntime =
        require(
          "../db/matilda-conversation-runtime",
        ) as typeof import(
          "../db/matilda-conversation-runtime"
        );

      const interpretationRuntime =
        require(
          "../db/matilda-interpretation-runtime",
        ) as typeof import(
          "../db/matilda-interpretation-runtime"
        );

      const workflowRuntime =
        require(
          "./matilda-chat-workflow",
        ) as typeof import(
          "./matilda-chat-workflow"
        );

      const activeConversation =
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          );

      const explicitTargetConversation =
        conversationRuntime
          .createMatildaConversation(
            "hq",
          );

      conversationRuntime
        .setActiveMatildaConversation(
          "hq",
          activeConversation.conversation_id,
        );

      assert.notEqual(
        explicitTargetConversation.conversation_id,
        activeConversation.conversation_id,
      );

      assert.equal(
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          )
          .conversation_id,
        activeConversation.conversation_id,
      );

      const beforeTargetEntries =
        interpretationRuntime
          .listInterpretationEvidenceLedgerEntries(
            100,
            {
              projectId: "hq",
              conversationId:
                explicitTargetConversation
                  .conversation_id,
            },
          );

      const beforeTargetTurns =
        conversationRuntime
          .listMatildaConversationTurns(
            "hq",
            100,
            explicitTargetConversation
              .conversation_id,
          );

      assert.equal(
        beforeTargetEntries.length,
        0,
      );

      assert.equal(
        beforeTargetTurns.length,
        0,
      );

      const result =
        await workflowRuntime
          .runMatildaConversationWorkflow({
            message:
              "Please revise the reviewed interpretation.",
            agent: "matilda",
            project_id: "hq",
            conversation_id:
              explicitTargetConversation
                .conversation_id,
          });

      assert.equal(
        result.canonical_package_created,
        false,
      );

      assert.equal(
        result.delegation_authorized,
        false,
      );

      assert.equal(
        result.validation_authorized,
        false,
      );

      assert.equal(
        result.envelope_authorized,
        false,
      );

      assert.equal(
        result.execution_authorized,
        false,
      );

      assert.equal(
        result.draft_package_updated,
        true,
      );

      assert.equal(
        result.turn.conversation_id,
        explicitTargetConversation
          .conversation_id,
      );

      const afterTargetEntries =
        interpretationRuntime
          .listInterpretationEvidenceLedgerEntries(
            100,
            {
              projectId: "hq",
              conversationId:
                explicitTargetConversation
                  .conversation_id,
            },
          );

      const afterTargetTurns =
        conversationRuntime
          .listMatildaConversationTurns(
            "hq",
            100,
            explicitTargetConversation
              .conversation_id,
          );

      assert.equal(
        afterTargetEntries.length,
        1,
      );

      assert.equal(
        afterTargetTurns.length,
        1,
      );

      assert.equal(
        afterTargetEntries[0]
          ?.conversation_id,
        explicitTargetConversation
          .conversation_id,
      );

      assert.equal(
        afterTargetTurns[0]
          ?.user_message,
        "Please revise the reviewed interpretation.",
      );

      assert.equal(
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          )
          .conversation_id,
        activeConversation.conversation_id,
      );

      database = new Database(
        path.join(
          temporaryRoot,
          "db",
          "main.db",
        ),
      );

      const draft =
        database
          .prepare(`
            SELECT
              draft_package_id,
              lineage_id,
              project_id,
              conversation_id,
              current_interpretation,
              proposed_work,
              expected_outcome,
              status,
              evidence_entry_ids
            FROM matilda_living_draft_packages
            WHERE draft_package_id = ?
            LIMIT 1
          `)
          .get(
            `matilda-draft-${explicitTargetConversation.conversation_id}`,
          ) as
          | {
              draft_package_id: string;
              lineage_id: string;
              project_id: string;
              conversation_id: string | null;
              current_interpretation: string;
              proposed_work: string | null;
              expected_outcome: string | null;
              status: string;
              evidence_entry_ids: string;
            }
          | undefined;

      assert.ok(draft);

      assert.equal(
        draft.project_id,
        "hq",
      );

      assert.equal(
        draft.conversation_id,
        explicitTargetConversation
          .conversation_id,
      );

      assert.equal(
        draft.status,
        "draft_non_authoritative",
      );

      assert.equal(
        draft.current_interpretation,
        "The reviewed intent should incorporate the requested correction while remaining non-authoritative.",
      );

      assert.equal(
        draft.expected_outcome,
        "Preserve the reviewed intent with the requested correction.",
      );

      assert.equal(
        draft.proposed_work,
        "Revise the reviewed interpretation using the supplied feedback.",
      );

      const evidenceIds =
        JSON.parse(
          draft.evidence_entry_ids,
        ) as string[];

      assert.equal(
        evidenceIds.length,
        1,
      );

      assert.equal(
        evidenceIds[0],
        afterTargetEntries[0]
          ?.entry_id,
      );

      const activeDraftCount =
        database
          .prepare(`
            SELECT COUNT(*) AS count
            FROM matilda_living_draft_packages
            WHERE conversation_id = ?
          `)
          .get(
            activeConversation
              .conversation_id,
          ) as {
            count: number;
          };

      assert.equal(
        activeDraftCount.count,
        0,
      );

      const canonicalTable =
        database
          .prepare(`
            SELECT name
            FROM sqlite_master
            WHERE type = 'table'
              AND name = 'matilda_canonical_packages'
            LIMIT 1
          `)
          .get() as
          | { name: string }
          | undefined;

      if (canonicalTable) {
        const canonicalCount =
          database
            .prepare(`
              SELECT COUNT(*) AS count
              FROM matilda_canonical_packages
            `)
            .get() as {
              count: number;
            };

        assert.equal(
          canonicalCount.count,
          0,
        );
      }
    } finally {
      database?.close();

      process.chdir(repositoryRoot);

      delete process.env.OLLAMA_BASE_URL;

      await closeServer(stub)
        .catch(() => undefined);

      rmSync(
        temporaryRoot,
        {
          recursive: true,
          force: true,
        },
      );
    }
  },
);
