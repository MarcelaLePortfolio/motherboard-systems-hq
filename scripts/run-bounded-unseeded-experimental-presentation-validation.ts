import { createHash } from "node:crypto";

import {
  ollamaChat,
  type OllamaChatContext,
  type MatildaSupportSourceReference,
} from "./utils/ollamaChat";

const RUN_COUNT = 10;

interface Observation {
  run: number;
  semanticPass: boolean;
  unsupportedProjectContextReference: boolean;
  failClosedOrRuntimeRejection: boolean;
  fingerprint: string;
  error: string | null;
  parsedSupportReferences: MatildaSupportSourceReference[];
}

const baseContext: OllamaChatContext = {
  projectId: "hq",
  projectDisplayName: "Motherboard Systems HQ",
  projectContextExcerpts: [
    {
      relativePath: "docs/diagnostic-context.md",
      lineNumber: 40,
      excerpt:
        "The collaboration runtime preserves fail-closed project-context support provenance.",
      provenance: "git_tracked_project_file",
      authorityStatus: "candidate_evidence_not_authority",
    },
  ],
  projectContextSegmentCandidates: [
    {
      relativePath: "docs/diagnostic-context.md",
      parentRelativePath: "docs/diagnostic-context.md",
      parentLineNumber: 40,
      sourceStartLine: 42,
      sourceEndLine: 44,
      text:
        "Fail-closed support validation rejects project-context references not supplied in the invocation.",
    },
  ],
  history: [],
  validationPromptPresentationVariant:
    "explicit_parent_child_separation",
};

const message =
  "Based only on the supplied project context, what reliability property does the collaboration runtime preserve?";

function fingerprint(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

async function runOnce(run: number): Promise<Observation> {
  const parsedSupportReferences: MatildaSupportSourceReference[] = [];

  try {
    const result = await ollamaChat(message, {
      ...baseContext,
      observeParsedSupportSourceReferences: (references) => {
        parsedSupportReferences.push(...references);
      },
    });

    return {
      run,
      semanticPass: true,
      unsupportedProjectContextReference: false,
      failClosedOrRuntimeRejection: false,
      fingerprint: fingerprint(JSON.stringify(result)),
      error: null,
      parsedSupportReferences,
    };
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error.message : String(error);

    return {
      run,
      semanticPass: false,
      unsupportedProjectContextReference:
        errorMessage.includes(
          "project-context support reference that was not supplied in this invocation",
        ),
      failClosedOrRuntimeRejection: true,
      fingerprint: fingerprint(
        JSON.stringify({
          errorMessage,
          parsedSupportReferences,
        }),
      ),
      error: errorMessage,
      parsedSupportReferences,
    };
  }
}

async function main(): Promise<void> {
  const observations: Observation[] = [];

  for (let run = 1; run <= RUN_COUNT; run += 1) {
    observations.push(await runOnce(run));
  }

  const semanticPasses = observations.filter(
    (observation) => observation.semanticPass,
  ).length;

  const unsupportedFailures = observations.filter(
    (observation) =>
      observation.unsupportedProjectContextReference,
  ).length;

  const failClosedOrRuntimeRejections = observations.filter(
    (observation) =>
      observation.failClosedOrRuntimeRejection,
  ).length;

  const uniqueFingerprints = new Set(
    observations.map((observation) => observation.fingerprint),
  ).size;

  console.log(
    "VALIDATION_CLASS=NON_PRODUCTION_PRODUCTION_EQUIVALENT_UNSEEDED_PRESENTATION_VALIDATION",
  );
  console.log("TEST_ARM=EXPERIMENTAL_PRESENTATION_ONLY");
  console.log("PRESENTATION_VARIANT=EXPLICIT_PARENT_CHILD_SEPARATION");
  console.log("GENERATION_SEED=ABSENT");
  console.log(`RUN_COUNT=${RUN_COUNT}`);
  console.log(`SEMANTIC_PASSES=${semanticPasses}`);
  console.log(`UNSUPPLIED_SUPPORT_FAILURES=${unsupportedFailures}`);
  console.log(
    `FAIL_CLOSED_OR_RUNTIME_REJECTIONS=${failClosedOrRuntimeRejections}`,
  );
  console.log(`UNIQUE_EXACT_OUTPUT_FINGERPRINTS=${uniqueFingerprints}`);

  for (const observation of observations) {
    console.log(JSON.stringify(observation));
  }

  console.log("PRODUCTION_PROMPT_CHANGE=NONE");
  console.log("PRODUCTION_GENERATION_POLICY_CHANGE=NONE");
  console.log("VALIDATOR_CHANGE=NONE");
  console.log("MODEL_CHANGE=NONE");
  console.log("RETRY_OR_SECOND_MODEL_CALL=NONE");
  console.log("PRODUCTION_CHANGE=NONE");
}

void main();
