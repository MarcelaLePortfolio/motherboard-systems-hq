import crypto from "crypto";
import path from "path";
import { pathToFileURL } from "url";

import {
  listInterpretationEvidenceLedgerEntries,
} from "../db/matilda-interpretation-runtime";
import {
  listMatildaConversationTurns,
} from "../db/matilda-conversation-runtime";
import {
  ollamaChat,
  type MatildaInvestigationLifecycleArtifact,
  type MatildaSelectedContextSegment,
  type MatildaSupportSourceReference,
} from "./utils/ollamaChat";
import {
  retrieveMatildaProjectContext,
} from "../server/matilda-project-context-retrieval";
import {
  composeMatildaConversationContext,
} from "../server/matilda-conversation-context-runtime";
import {
  selectMatildaInterpretationLifecycleEntries,
} from "../server/matilda-interpretation-lifecycle-provider";
import {
  isExplicitExplanationRequest,
} from "../server/matilda-explanation-request-signal";
import {
  isExplicitEvidenceRequest,
} from "../server/matilda-evidence-request-signal";
import {
  recoverMatildaPriorSupportProvenance,
} from "../server/matilda-prior-support-provenance";

const PROJECT_ID = "hq";
const CONVERSATION_ID =
  "matilda-conversation-hq-1787159584712-q6x7o3";
const MESSAGE =
  "Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.";

const UNSEEDED_RUNS = 10;
const CONTROLLED_RUNS = 10;
const CONTROLLED_SEED = 424242;

type Arm = "UNSEEDED" | "CONTROLLED";

interface RunRecord {
  arm: Arm;
  run: number;
  seed: number | null;
  accepted: boolean;
  failureClass: string | null;
  errorMessage: string | null;
  parsedSelectedContextCount: number | null;
  validatedSelectedContextCount: number | null;
  parsedSupportReferenceCount: number | null;
  parsedSupportReferences:
    | readonly MatildaSupportSourceReference[]
    | null;
  fingerprint: string | null;
  reply: string | null;
  durableInterpretation: string | null;
}

function fingerprint(value: unknown): string {
  return crypto
    .createHash("sha256")
    .update(JSON.stringify(value))
    .digest("hex");
}

function classifyFailure(error: unknown): string {
  const message =
    error instanceof Error ? error.message : String(error);

  if (/timed out|timeout|abort/i.test(message)) {
    return "OLLAMA_TIMEOUT";
  }

  if (
    /conversation support reference.*not supplied/i.test(message)
  ) {
    return "UNSUPPLIED_CONVERSATION_SUPPORT_REFERENCE";
  }

  if (
    /project-context support reference.*not supplied/i.test(message)
  ) {
    return "UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE";
  }

  if (
    /selected context segment.*not supplied/i.test(message)
  ) {
    return "UNSUPPLIED_SELECTED_CONTEXT_SEGMENT";
  }

  if (/malformed structured response/i.test(message)) {
    return "MALFORMED_STRUCTURED_RESPONSE";
  }

  if (/investigation lifecycle/i.test(message)) {
    return "INVESTIGATION_LIFECYCLE_REJECTION";
  }

  return "OTHER_FAIL_CLOSED_OR_RUNTIME_REJECTION";
}

function selectPriorInvestigationLifecycle(
  entries: ReturnType<
    typeof listInterpretationEvidenceLedgerEntries
  >,
): MatildaInvestigationLifecycleArtifact | null {
  const eligible = entries.find(
    (entry) => entry.investigationLifecycle !== null,
  );

  return eligible?.investigationLifecycle ?? null;
}

async function buildSnapshot() {
  const registryPath = pathToFileURL(
    path.resolve(
      process.cwd(),
      "server",
      "project-registry.mjs",
    ),
  ).href;

  const { getProjectRegistryState } =
    await import(registryPath);

  const registryState = getProjectRegistryState();

  const project = registryState.projects.find(
    (candidate: {
      projectId: string;
      displayName?: string | null;
      projectRootPath?: string | null;
    }) => candidate.projectId === PROJECT_ID,
  );

  const projectDisplayName =
    project?.displayName ?? null;
  const projectRootPath =
    project?.projectRootPath ?? null;

  const projectContextRetrieval =
    retrieveMatildaProjectContext({
      projectId: PROJECT_ID,
      projectRootPath,
      message: MESSAGE,
    });

  const conversationTurns =
    listMatildaConversationTurns(
      PROJECT_ID,
      20,
      CONVERSATION_ID,
    );

  const interpretationLedgerEntries =
    listInterpretationEvidenceLedgerEntries(500);

  const scopedLifecycleLedgerEntries =
    listInterpretationEvidenceLedgerEntries(
      100,
      {
        projectId: PROJECT_ID,
        conversationId: CONVERSATION_ID,
      },
    );

  const priorInvestigationLifecycle =
    selectPriorInvestigationLifecycle(
      scopedLifecycleLedgerEntries,
    );

  const interpretationLifecycleEntries =
    selectMatildaInterpretationLifecycleEntries(
      conversationTurns.map(
        (turn) => turn.interpretation_entry_id,
      ),
      interpretationLedgerEntries,
    );

  const conversationContext =
    composeMatildaConversationContext({
      turns: conversationTurns,
      projectContextRetrieval,
      interpretationLifecycleEntries,
    });

  const history =
    conversationContext.selectedHistory;

  const explicitExplanationRequest =
    isExplicitExplanationRequest(MESSAGE);

  const explicitEvidenceRequest =
    isExplicitEvidenceRequest(MESSAGE);

  const priorSupportProvenance =
    explicitExplanationRequest
      ? recoverMatildaPriorSupportProvenance(
          history,
          interpretationLedgerEntries,
        )
      : null;

  return {
    projectDisplayName,
    history: structuredClone(history),
    projectContextExcerpts:
      structuredClone(
        conversationContext.projectContextExcerpts,
      ),
    projectContextSegmentCandidates:
      structuredClone(
        conversationContext.projectContextSegmentCandidates,
      ),
    projectContextWarning:
      conversationContext.projectContextWarning,
    priorExplanationEvidenceStatus:
      priorSupportProvenance?.status,
    priorInvestigationLifecycle:
      priorInvestigationLifecycle
        ? structuredClone(priorInvestigationLifecycle)
        : null,
    explicitEvidenceRequest,
  };
}

async function runOnce(
  arm: Arm,
  run: number,
  snapshot: Awaited<
    ReturnType<typeof buildSnapshot>
  >,
): Promise<RunRecord> {
  let parsedSelected:
    readonly MatildaSelectedContextSegment[] | undefined;
  let validatedSelected:
    readonly MatildaSelectedContextSegment[] | undefined;
  let parsedSupport:
    readonly MatildaSupportSourceReference[] | undefined;

  const seed =
    arm === "CONTROLLED"
      ? CONTROLLED_SEED
      : null;

  try {
    const result = await ollamaChat(
      MESSAGE,
      {
        projectId: PROJECT_ID,
        projectDisplayName:
          snapshot.projectDisplayName,
        history: snapshot.history,
        projectContextExcerpts:
          snapshot.projectContextExcerpts,
        projectContextSegmentCandidates:
          snapshot.projectContextSegmentCandidates,
        projectContextWarning:
          snapshot.projectContextWarning,
        priorExplanationEvidenceStatus:
          snapshot.priorExplanationEvidenceStatus,
        priorInvestigationLifecycle:
          snapshot.priorInvestigationLifecycle,
        explicitEvidenceRequest:
          snapshot.explicitEvidenceRequest,
        ...(seed === null
          ? {}
          : { validationGenerationSeed: seed }),
        observeParsedSelectedContextSegments:
          (segments) => {
            parsedSelected = [...segments];
          },
        observeValidatedSelectedContextSegments:
          (segments) => {
            validatedSelected = [...segments];
          },
        observeParsedSupportSourceReferences:
          (references) => {
            parsedSupport = [...references];
          },
      },
    );

    const output = {
      reply: result.reply,
      explanationStatus:
        result.explanationStatus,
      supportSourceReferences:
        result.supportSourceReferences,
      evidence: result.evidence,
      evidenceSufficient:
        result.evidenceSufficient,
      investigationLifecycle:
        result.investigationLifecycle,
      durableInterpretation:
        result.durableInterpretation,
    };

    return {
      arm,
      run,
      seed,
      accepted: true,
      failureClass: null,
      errorMessage: null,
      parsedSelectedContextCount:
        parsedSelected?.length ?? null,
      validatedSelectedContextCount:
        validatedSelected?.length ?? null,
      parsedSupportReferenceCount:
        parsedSupport?.length ?? null,
      parsedSupportReferences:
        parsedSupport ? [...parsedSupport] : null,
      fingerprint: fingerprint(output),
      reply: result.reply,
      durableInterpretation:
        result.durableInterpretation,
    };
  } catch (error) {
    return {
      arm,
      run,
      seed,
      accepted: false,
      failureClass: classifyFailure(error),
      errorMessage:
        error instanceof Error
          ? error.message
          : String(error),
      parsedSelectedContextCount:
        parsedSelected?.length ?? null,
      validatedSelectedContextCount:
        validatedSelected?.length ?? null,
      parsedSupportReferenceCount:
        parsedSupport?.length ?? null,
      parsedSupportReferences:
        parsedSupport ? [...parsedSupport] : null,
      fingerprint: null,
      reply: null,
      durableInterpretation: null,
    };
  }
}

function summarize(
  arm: Arm,
  records: RunRecord[],
) {
  const armRecords =
    records.filter(
      (record) => record.arm === arm,
    );

  const accepted =
    armRecords.filter(
      (record) => record.accepted,
    ).length;

  const rejected =
    armRecords.length - accepted;

  const fingerprints =
    new Set(
      armRecords
        .map((record) => record.fingerprint)
        .filter(
          (value): value is string =>
            typeof value === "string",
        ),
    );

  const failures =
    new Map<string, number>();

  for (const record of armRecords) {
    if (!record.failureClass) {
      continue;
    }

    failures.set(
      record.failureClass,
      (failures.get(record.failureClass) ?? 0) + 1,
    );
  }

  return {
    arm,
    total: armRecords.length,
    accepted,
    rejected,
    uniqueAcceptedFingerprints:
      fingerprints.size,
    failureClasses:
      Object.fromEntries(failures),
  };
}

async function main() {
  console.log(
    "CHECKPOINT=MATILDA_UI_SMOKE_TEST_503",
  );
  console.log(
    "AUTHORIZATION=EXPLICIT_USER_AUTHORIZATION_RECEIVED",
  );
  console.log(
    "EXPERIMENT_CLASS=VALIDATION_ONLY",
  );
  console.log(
    "PRODUCTION_FILE_MUTATION=NONE",
  );
  console.log("DATABASE_WRITE=NONE");
  console.log(
    "CAUSAL_VARIABLE=validationGenerationSeed_ONLY",
  );
  console.log(
    `CONTROLLED_SEED=${CONTROLLED_SEED}`,
  );

  const snapshot = await buildSnapshot();

  console.log();
  console.log("=== SNAPSHOT ===");
  console.log(`PROJECT_ID=${PROJECT_ID}`);
  console.log(
    `CONVERSATION_ID=${CONVERSATION_ID}`,
  );
  console.log(
    `HISTORY_COUNT=${snapshot.history.length}`,
  );
  console.log(
    `PROJECT_CONTEXT_EXCERPT_COUNT=${snapshot.projectContextExcerpts.length}`,
  );
  console.log(
    `PROJECT_CONTEXT_SEGMENT_COUNT=${snapshot.projectContextSegmentCandidates.length}`,
  );

  const records: RunRecord[] = [];

  for (
    let run = 1;
    run <= UNSEEDED_RUNS;
    run += 1
  ) {
    console.log(
      `\n=== UNSEEDED RUN ${run}/${UNSEEDED_RUNS} ===`,
    );
    const record = await runOnce(
      "UNSEEDED",
      run,
      snapshot,
    );
    records.push(record);
    console.log(JSON.stringify(record, null, 2));
  }

  for (
    let run = 1;
    run <= CONTROLLED_RUNS;
    run += 1
  ) {
    console.log(
      `\n=== CONTROLLED RUN ${run}/${CONTROLLED_RUNS} ===`,
    );
    const record = await runOnce(
      "CONTROLLED",
      run,
      snapshot,
    );
    records.push(record);
    console.log(JSON.stringify(record, null, 2));
  }

  const unseededSummary =
    summarize("UNSEEDED", records);
  const controlledSummary =
    summarize("CONTROLLED", records);

  console.log("\n=== COMPARISON SUMMARY ===");
  console.log(
    JSON.stringify(
      {
        unseeded: unseededSummary,
        controlled: controlledSummary,
      },
      null,
      2,
    ),
  );

  console.log("\n=== ACCEPTANCE BOUNDARY ===");
  console.log(
    `PRIMARY_CONTROL_CRITERION_CONTROLLED_10_OF_10=${
      controlledSummary.accepted ===
      CONTROLLED_RUNS
        ? "PASS"
        : "FAIL"
    }`,
  );
  console.log(
    `COMPARATIVE_CRITERION_FEWER_CONTROLLED_FAILURES=${
      controlledSummary.rejected <
      unseededSummary.rejected
        ? "PASS"
        : "FAIL"
    }`,
  );
  console.log(
    "SEMANTIC_CRITERION=REQUIRES_REVIEW_OF_ACCEPTED_OUTPUTS",
  );
  console.log(
    "PRODUCTION_PROMOTION_AUTHORIZED=NO",
  );
  console.log(
    "VALIDATOR_WEAKENING_AUTHORIZED=NO",
  );
  console.log(
    "PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=NO",
  );
  console.log("ISSUE_RESOLVED=NO");
  console.log(
    "NEXT_ACTION=CLASSIFY_COMPARISON_RESULT_AND_SEMANTIC_PRESERVATION_BEFORE_ANY_PRODUCTION_CHANGE",
  );
}

main().catch((error) => {
  console.error(
    "COMPARISON_SETUP_OR_RUNNER_FAILURE",
  );
  console.error(error);
  process.exitCode = 1;
});
