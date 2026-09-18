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

    let ollamaInvocationCount = 0;
    let latestOllamaRequestBody = "";

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

          ollamaInvocationCount += 1;
          latestOllamaRequestBody = body;

          const structuredResponse = {
            reply:
              "I incorporated the requested revision.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
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

      const historicalObservationRuntime =
        require(
          "../db/atlas-historical-observation-persistence",
        ) as typeof import(
          "../db/atlas-historical-observation-persistence"
        );

      const historicalObservationAdapter =
        require(
          "./atlas/atlas-historical-observation-adapter",
        ) as typeof import(
          "./atlas/atlas-historical-observation-adapter"
        );

      const preexecutionObservationAggregator =
        require(
          "./atlas/atlas-preexecution-observation-aggregator",
        ) as typeof import(
          "./atlas/atlas-preexecution-observation-aggregator"
        );

      const {
        readAtlasHistoricalObservations,
      } = historicalObservationRuntime;

      const {
        readAtlasHistoricalTypedObservations,
      } = historicalObservationAdapter;

      const {
        readAtlasTypedPreexecutionObservations,
      } = preexecutionObservationAggregator;

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

      database = new Database(
        path.join(
          temporaryRoot,
          "db",
          "main.db",
        ),
      );

      const backfillConversation =
        conversationRuntime
          .createMatildaConversation(
            "hq",
          );

      conversationRuntime
        .setActiveMatildaConversation(
          "hq",
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

      database.exec(`
        CREATE TABLE IF NOT EXISTS matilda_canonical_packages (
          package_id TEXT NOT NULL,
          package_version INTEGER NOT NULL CHECK (package_version >= 1),
          summary_id TEXT NOT NULL,
          draft_package_id TEXT NOT NULL,
          draft_revision_id TEXT,
          lineage_id TEXT NOT NULL,
          project_id TEXT,
          conversation_id TEXT,
          approved_interpretation TEXT NOT NULL,
          approved_work TEXT,
          approved_artifacts TEXT,
          approved_scope TEXT,
          approved_constraints TEXT,
          approved_expected_outcome TEXT,
          approval_actor TEXT NOT NULL,
          approval_timestamp TEXT NOT NULL,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          PRIMARY KEY (package_id, package_version)
        );
      `);

      database.exec(`
        CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger (
          entry_id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          actor TEXT NOT NULL,
          project_id TEXT NOT NULL,
          conversation_id TEXT,
          interpretation_event TEXT NOT NULL,
          minimum_sufficient_context TEXT NOT NULL,
          supporting_raw_evidence TEXT NOT NULL,
          matilda_observation TEXT NOT NULL,
          unresolved_questions TEXT,
          lineage_references TEXT,
          supersession_status TEXT NOT NULL
        );
      `);

      const insertLedger =
        database.prepare(`
          INSERT INTO matilda_interpretation_evidence_ledger (
            entry_id,
            created_at,
            actor,
            project_id,
            conversation_id,
            interpretation_event,
            minimum_sufficient_context,
            supporting_raw_evidence,
            matilda_observation,
            unresolved_questions,
            lineage_references,
            supersession_status
          ) VALUES (
            ?,
            ?,
            'matilda',
            'hq',
            ?,
            'Backfill regression fixture',
            'fixture',
            ?,
            ?,
            NULL,
            NULL,
            ?
          )
        `);

      const insertTurn =
        database.prepare(`
          INSERT INTO matilda_conversation_turns (
            turn_id,
            project_id,
            conversation_id,
            user_message,
            assistant_reply,
            interpretation_entry_id,
            project_context_evidence_trace_json,
            created_at
          ) VALUES (
            ?,
            'hq',
            ?,
            ?,
            ?,
            ?,
            NULL,
            ?
          )
        `);

      for (
        let index = 1;
        index <= 40;
        index += 1
      ) {
        const suffix =
          String(index).padStart(3, "0");

        const createdAt =
          `2026-09-16T00:00:${String(index).padStart(2, "0")}.000Z`;

        const entryId =
          `backfill-iel-${suffix}`;

        const turnId =
          `backfill-turn-${suffix}`;

        const isRecentIneligible =
          index > 20;

        const supportPayload =
          JSON.stringify({
            supportSourceReferences: [],
            evidenceSufficient: true,
          });

        insertLedger.run(
          entryId,
          createdAt,
          backfillConversation.conversation_id,
          supportPayload,
          `Backfill interpretation ${suffix}`,
          isRecentIneligible
            ? "superseded"
            : "current",
        );

        insertTurn.run(
          turnId,
          backfillConversation.conversation_id,
          `Backfill user ${suffix}`,
          `Backfill assistant ${suffix}`,
          entryId,
          createdAt,
        );
      }

      const ollamaBeforeBackfill =
        ollamaInvocationCount;

      const backfillResult =
        await workflowRuntime
          .runMatildaConversationWorkflow({
            message:
              "Use the eligible conversation history.",
            agent: "matilda",
            project_id: "hq",
            conversation_id:
              backfillConversation
                .conversation_id,
          });

      assert.equal(
        ollamaInvocationCount
          - ollamaBeforeBackfill,
        1,
      );

      assert.equal(
        backfillResult.turn.conversation_id,
        backfillConversation
          .conversation_id,
      );

      assert.ok(
        latestOllamaRequestBody.includes(
          "Backfill user 001",
        ),
      );

      assert.ok(
        latestOllamaRequestBody.includes(
          "Backfill user 020",
        ),
      );

      assert.equal(
        latestOllamaRequestBody.includes(
          "Backfill user 021",
        ),
        false,
      );

      assert.equal(
        latestOllamaRequestBody.includes(
          "Backfill user 040",
        ),
        false,
      );

      const firstEligibleIndex =
        latestOllamaRequestBody.indexOf(
          "Backfill user 001",
        );

      const lastEligibleIndex =
        latestOllamaRequestBody.indexOf(
          "Backfill user 020",
        );

      assert.ok(firstEligibleIndex >= 0);
      assert.ok(lastEligibleIndex > firstEligibleIndex);

      const backfillTurnCount =
        database
          .prepare(`
            SELECT COUNT(*) AS count
            FROM matilda_conversation_turns
            WHERE project_id = 'hq'
              AND conversation_id = ?
          `)
          .get(
            backfillConversation
              .conversation_id,
          ) as {
            count: number;
          };

      assert.equal(
        backfillTurnCount.count,
        41,
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

      const historicalRecords =
        readAtlasHistoricalObservations(
          "hq",
          database,
        );

      const targetHistoricalRecords =
        historicalRecords.filter(
          (observation) =>
            observation.conversationId ===
            explicitTargetConversation.conversation_id,
        );

      const historicalInterpretationEvidence =
        targetHistoricalRecords.filter(
          (observation) =>
            observation.sourceKind ===
            "interpretation_evidence",
        );

      const historicalLivingDrafts =
        targetHistoricalRecords.filter(
          (observation) =>
            observation.sourceKind ===
            "living_draft",
        );

      assert.equal(
        historicalInterpretationEvidence.length,
        1,
      );

      assert.ok(
        historicalLivingDrafts.length >= 1,
      );

      assert.equal(
        historicalInterpretationEvidence[0]
          ?.authorityStatus,
        "matilda_authored_interpretive_evidence",
      );

      assert.ok(
        historicalLivingDrafts.every(
          (observation) =>
            observation.authorityStatus ===
            "non_authoritative" &&
            observation.conversationId ===
            explicitTargetConversation.conversation_id,
        ),
      );

      const databasePath =
        path.join(
          temporaryRoot,
          "db",
          "main.db",
        );

      const typedHistorical =
        readAtlasHistoricalTypedObservations(
          "hq",
          databasePath,
        ).filter(
          (observation) =>
            observation.observation.conversationId ===
            explicitTargetConversation.conversation_id,
        );

      assert.equal(
        typedHistorical.filter(
          (observation) =>
            observation.observationKind ===
            "interpretation_evidence",
        ).length,
        1,
      );

      assert.ok(
        typedHistorical
          .filter(
            (observation) =>
              observation.observationKind ===
              "living_draft",
          )
          .every(
            (observation) =>
              observation.authorityStatus ===
              "non_authoritative",
          ),
      );

      const merged =
        readAtlasTypedPreexecutionObservations({
          projectId: "hq",
          conversationId:
            explicitTargetConversation.conversation_id,
          databasePath,
        });

      const mergedInterpretationEvidence =
        merged.filter(
          (observation) =>
            observation.sourceKind ===
              "interpretation_evidence" &&
            observation.payload.entryId ===
              afterTargetEntries[0]?.entry_id,
        );

      assert.equal(
        mergedInterpretationEvidence.length,
        1,
      );

      const mergedDrafts =
        merged.filter(
          (observation) =>
            observation.sourceKind ===
              "living_draft" &&
            observation.payload.draftPackageId ===
              draft.draft_package_id,
        );

      const mergedDraftRevisionKeys =
        mergedDrafts.map(
          (observation) =>
            `${observation.payload.draftPackageId}\u0000${observation.payload.updatedAt}`,
        );

      assert.equal(
        new Set(mergedDraftRevisionKeys).size,
        mergedDraftRevisionKeys.length,
      );

      const chronological =
        merged.map(
          (observation) =>
            observation.observedAt,
        );

      assert.deepEqual(
        chronological,
        [...chronological].sort(),
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
