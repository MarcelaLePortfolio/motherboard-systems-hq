import assert from "node:assert/strict";
import {
  copyFileSync,
  mkdirSync,
  mkdtempSync,
  rmSync,
  symlinkSync,
} from "node:fs";
import { createServer, type Server } from "node:http";
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

function createResponse() {
  let statusCode = 200;
  let body: unknown = null;

  return {
    response: {
      status(code: number) {
        statusCode = code;
        return this;
      },

      json(value: unknown) {
        body = value;
        return this;
      },
    } as any,

    read() {
      return {
        statusCode,
        body,
      };
    },
  };
}

test(
  "Request Changes resolves the persisted pending draft and runs the real shared workflow against its non-active originating conversation",
  async () => {
    const temporaryRoot = mkdtempSync(
      path.join(
        tmpdir(),
        "request-changes-route-integration-",
      ),
    );

    const temporaryDbDirectory =
      path.join(temporaryRoot, "db");

    const temporaryServerDirectory =
      path.join(temporaryRoot, "server");

    mkdirSync(
      temporaryDbDirectory,
      {
        recursive: true,
      },
    );

    mkdirSync(
      temporaryServerDirectory,
      {
        recursive: true,
      },
    );

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
      path.join(
        repositoryRoot,
        "node_modules",
      ),
      path.join(
        temporaryRoot,
        "node_modules",
      ),
      "dir",
    );

    const ollamaStub = createServer(
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

        request.on(
          "data",
          (chunk) => {
            body += chunk;
          },
        );

        request.on(
          "end",
          () => {
            assert.ok(
              body.length > 0,
            );

            const structuredResponse = {
              reply:
                "I incorporated the requested correction.",
              explanationStatus:
                "optional",
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

            response.writeHead(
              200,
              {
                "content-type":
                  "application/json",
              },
            );

            response.end(
              JSON.stringify({
                response:
                  JSON.stringify(
                    structuredResponse,
                  ),
                done: true,
              }),
            );
          },
        );
      },
    );

    let database:
      Database.Database | null = null;

    try {
      const port =
        await listen(
          ollamaStub,
        );

      process.env.OLLAMA_BASE_URL =
        `http://127.0.0.1:${port}`;

      process.chdir(
        temporaryRoot,
      );

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

      const livingDraftRuntime =
        require(
          "../db/matilda-living-draft-runtime",
        ) as typeof import(
          "../db/matilda-living-draft-runtime"
        );

      const {
        createRequestChangesHandler,
      } = require(
        "./api-request-changes",
      ) as typeof import(
        "./api-request-changes"
      );

      const activeConversation =
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          );

      const originatingConversation =
        conversationRuntime
          .createMatildaConversation(
            "hq",
          );

      conversationRuntime
        .setActiveMatildaConversation(
          "hq",
          activeConversation
            .conversation_id,
        );

      assert.notEqual(
        originatingConversation
          .conversation_id,
        activeConversation
          .conversation_id,
      );

      assert.equal(
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          )
          .conversation_id,
        activeConversation
          .conversation_id,
      );

      interpretationRuntime
        .createInterpretationEvidenceLedgerEntry({
          entry_id:
            "iel-reviewed-source",
          actor:
            "matilda",
          project_id:
            "hq",
          conversation_id:
            originatingConversation
              .conversation_id,
          interpretation_event:
            "Reviewed source interpretation",
          minimum_sufficient_context:
            "Isolated Request Changes integration fixture",
          supporting_raw_evidence:
            "Fixture evidence",
          matilda_observation:
            "Original reviewed interpretation.",
          unresolved_questions:
            null,
          lineage_references:
            `conversation:${originatingConversation.conversation_id}`,
          supersession_status:
            "current",
          investigation_lifecycle:
            null,
          package_semantics: {
            expectedOutcome:
              "Original reviewed expected outcome.",
            proposedWork:
              "Original reviewed proposed work.",
            proposedArtifacts:
              null,
            inScope:
              "Original reviewed scope.",
            outOfScope:
              "Downstream execution authority.",
            constraints:
              "Remain non-authoritative.",
            unresolvedQuestions:
              null,
          },
        });

      conversationRuntime
        .createMatildaConversationTurn({
          project_id:
            "hq",
          conversation_id:
            originatingConversation
              .conversation_id,
          user_message:
            "Original reviewed request.",
          assistant_reply:
            "Original reviewed interpretation.",
          interpretation_entry_id:
            "iel-reviewed-source",
          project_context_retrieval: {
            projectId:
              "hq",
            projectRootPath:
              temporaryRoot,
            available:
              true,
            searched:
              false,
            queryTerms:
              [],
            excerpts:
              [],
            warning:
              null,
          },
        });

      assert.equal(
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          )
          .conversation_id,
        activeConversation
          .conversation_id,
      );

      livingDraftRuntime
        .upsertLivingDraftPackage({
          draft_package_id:
            `matilda-draft-${originatingConversation.conversation_id}`,
          lineage_id:
            `matilda-lineage-${originatingConversation.conversation_id}`,
          project_id:
            "hq",
          conversation_id:
            originatingConversation
              .conversation_id,
          current_interpretation:
            "Original reviewed interpretation.",
          proposed_work:
            "Original reviewed proposed work.",
          proposed_artifacts:
            null,
          in_scope:
            "Original reviewed scope.",
          out_of_scope:
            "Downstream execution authority.",
          constraints:
            "Remain non-authoritative.",
          expected_outcome:
            "Original reviewed expected outcome.",
          unresolved_questions:
            null,
          evidence_entry_ids: [
            "iel-reviewed-source",
          ],
          status:
            "draft_non_authoritative",
        });

      database = new Database(
        path.join(
          temporaryRoot,
          "db",
          "main.db",
        ),
      );

      database.exec(`
        CREATE TABLE IF NOT EXISTS matilda_canonical_packages (
          package_id TEXT PRIMARY KEY,
          package_version INTEGER NOT NULL,
          draft_package_id TEXT NOT NULL,
          lineage_id TEXT NOT NULL,
          project_id TEXT,
          conversation_id TEXT,
          approved_interpretation TEXT NOT NULL,
          approved_work TEXT,
          approved_artifacts TEXT,
          approved_in_scope TEXT,
          approved_out_of_scope TEXT,
          approved_constraints TEXT,
          approved_expected_outcome TEXT,
          approved_unresolved_questions TEXT,
          approval_request_id TEXT,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL
        );
      `);

      const handler =
        createRequestChangesHandler();

      const response =
        createResponse();

      await handler(
        {
          body: {
            approval_request_id:
              `canonical_package_approval:matilda-draft-${originatingConversation.conversation_id}`,
            feedback:
              " Please correct the reviewed interpretation. ",
            project_id:
              "untrusted-client-project",
            conversation_id:
              "untrusted-client-conversation",
          },
        } as any,
        response.response,
      );

      const result =
        response.read();

      assert.equal(
        result.statusCode,
        200,
      );

      const responseBody =
        result.body as {
          ok: boolean;
          reply: string;
          canonical_package_created: boolean;
          delegation_authorized: boolean;
          validation_authorized: boolean;
          envelope_authorized: boolean;
          execution_authorized: boolean;
        };

      assert.equal(
        responseBody.ok,
        true,
      );

      assert.equal(
        responseBody.canonical_package_created,
        false,
      );

      assert.equal(
        responseBody.delegation_authorized,
        false,
      );

      assert.equal(
        responseBody.validation_authorized,
        false,
      );

      assert.equal(
        responseBody.envelope_authorized,
        false,
      );

      assert.equal(
        responseBody.execution_authorized,
        false,
      );

      const originatingEntries =
        interpretationRuntime
          .listInterpretationEvidenceLedgerEntries(
            100,
            {
              projectId:
                "hq",
              conversationId:
                originatingConversation
                  .conversation_id,
            },
          );

      assert.equal(
        originatingEntries.length,
        2,
      );

      const originatingTurns =
        conversationRuntime
          .listMatildaConversationTurns(
            "hq",
            100,
            originatingConversation
              .conversation_id,
          );

      assert.equal(
        originatingTurns.length,
        2,
      );

      assert.equal(
        originatingTurns[0]
          ?.user_message,
        "Original reviewed request.",
      );

      assert.equal(
        originatingTurns[1]
          ?.user_message,
        "Please correct the reviewed interpretation.",
      );

      assert.equal(
        originatingTurns[1]
          ?.conversation_id,
        originatingConversation
          .conversation_id,
      );

      assert.equal(
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          )
          .conversation_id,
        activeConversation
          .conversation_id,
      );

      const updatedDraft =
        database
          .prepare(`
            SELECT
              draft_package_id,
              project_id,
              conversation_id,
              current_interpretation,
              proposed_work,
              expected_outcome,
              evidence_entry_ids,
              status
            FROM matilda_living_draft_packages
            WHERE draft_package_id = ?
            LIMIT 1
          `)
          .get(
            `matilda-draft-${originatingConversation.conversation_id}`,
          ) as {
            draft_package_id: string;
            project_id: string;
            conversation_id: string;
            current_interpretation: string;
            proposed_work: string | null;
            expected_outcome: string | null;
            evidence_entry_ids: string;
            status: string;
          };

      assert.equal(
        updatedDraft.project_id,
        "hq",
      );

      assert.equal(
        updatedDraft.conversation_id,
        originatingConversation
          .conversation_id,
      );

      assert.equal(
        updatedDraft.status,
        "draft_non_authoritative",
      );

      assert.match(
        updatedDraft.current_interpretation,
        /requested correction while remaining non-authoritative/,
      );

      assert.equal(
        updatedDraft.expected_outcome,
        "Preserve the reviewed intent with the requested correction.",
      );

      const updatedEvidenceIds =
        JSON.parse(
          updatedDraft
            .evidence_entry_ids,
        ) as string[];

      assert.equal(
        updatedEvidenceIds.length,
        2,
      );

      assert.ok(
        updatedEvidenceIds.includes(
          "iel-reviewed-source",
        ),
      );

      assert.ok(
        updatedEvidenceIds.includes(
          originatingTurns[1]
            .interpretation_entry_id,
        ),
      );

      const activeTurns =
        conversationRuntime
          .listMatildaConversationTurns(
            "hq",
            100,
            activeConversation
              .conversation_id,
          );

      assert.equal(
        activeTurns.length,
        0,
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
    } finally {
      database?.close();

      process.chdir(
        repositoryRoot,
      );

      delete process.env
        .OLLAMA_BASE_URL;

      await closeServer(
        ollamaStub,
      ).catch(
        () => undefined,
      );

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
