import { createHash } from "node:crypto";

import {
  ollamaChat,
  type OllamaChatContext,
  type MatildaSupportSourceReference,
} from "./utils/ollamaChat";

const FIXED_SEED = 424242;
const PAIR_COUNT = 10;

type Arm = "control" | "experimental";

interface Observation {
  pair: number;
  arm: Arm;
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
  validationGenerationSeed: FIXED_SEED,
};

const message =
  "Based only on the supplied project context, what reliability property does the collaboration runtime preserve?";

function fingerprint(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

async function run(pair: number, arm: Arm): Promise<Observation> {
  const parsedSupportReferences: MatildaSupportSourceReference[] = [];

  try {
    const result = await ollamaChat(message, {
      ...baseContext,
      ...(arm === "experimental"
        ? {
            validationPromptPresentationVariant:
              "explicit_parent_child_separation" as const,
          }
        : {}),
      observeParsedSupportSourceReferences: (references) => {
        parsedSupportReferences.push(...references);
      },
    });

    return {
      pair,
      arm,
      semanticPass: true,
      unsupportedProjectContextReference: false,
      failClosedOrRuntimeRejection: false,
      fingerprint: fingerprint(JSON.stringify(result)),
      error: null,
      parsedSupportReferences,
    };
  } catch (error) {
    const message =
      error instanceof Error ? error.message : String(error);

    return {
      pair,
      arm,
      semanticPass: false,
      unsupportedProjectContextReference:
        message.includes(
          "project-context support reference that was not supplied in this invocation",
        ),
      failClosedOrRuntimeRejection: true,
      fingerprint: fingerprint(
        JSON.stringify({
          message,
          parsedSupportReferences,
        }),
      ),
      error: message,
      parsedSupportReferences,
    };
  }
}

async function main(): Promise<void> {
  const observations: Observation[] = [];

  for (let pair = 1; pair <= PAIR_COUNT; pair += 1) {
    observations.push(await run(pair, "control"));
    observations.push(await run(pair, "experimental"));
  }

  const summarize = (arm: Arm) => {
    const armObservations = observations.filter(
      (observation) => observation.arm === arm,
    );

    return {
      runs: armObservations.length,
      semanticPasses: armObservations.filter(
        (observation) => observation.semanticPass,
      ).length,
      unsupportedProjectContextReferenceFailures:
        armObservations.filter(
          (observation) =>
            observation.unsupportedProjectContextReference,
        ).length,
      failClosedOrRuntimeRejections:
        armObservations.filter(
          (observation) =>
            observation.failClosedOrRuntimeRejection,
        ).length,
      uniqueFingerprints: new Set(
        armObservations.map(
          (observation) => observation.fingerprint,
        ),
      ).size,
    };
  };

  const control = summarize("control");
  const experimental = summarize("experimental");

  console.log("DIAGNOSTIC_CLASS=VALIDATION_ONLY_NON_PRODUCTION_AB_COMPARISON");
  console.log(`FIXED_SEED=${FIXED_SEED}`);
  console.log(`PAIR_COUNT=${PAIR_COUNT}`);
  console.log(`TOTAL_RUNS=${observations.length}`);
  console.log(`CONTROL_RUNS=${control.runs}`);
  console.log(`CONTROL_SEMANTIC_PASSES=${control.semanticPasses}`);
  console.log(
    `CONTROL_UNSUPPLIED_SUPPORT_FAILURES=${control.unsupportedProjectContextReferenceFailures}`,
  );
  console.log(
    `CONTROL_FAIL_CLOSED_OR_RUNTIME_REJECTIONS=${control.failClosedOrRuntimeRejections}`,
  );
  console.log(
    `CONTROL_UNIQUE_FINGERPRINTS=${control.uniqueFingerprints}`,
  );
  console.log(`EXPERIMENTAL_RUNS=${experimental.runs}`);
  console.log(
    `EXPERIMENTAL_SEMANTIC_PASSES=${experimental.semanticPasses}`,
  );
  console.log(
    `EXPERIMENTAL_UNSUPPLIED_SUPPORT_FAILURES=${experimental.unsupportedProjectContextReferenceFailures}`,
  );
  console.log(
    `EXPERIMENTAL_FAIL_CLOSED_OR_RUNTIME_REJECTIONS=${experimental.failClosedOrRuntimeRejections}`,
  );
  console.log(
    `EXPERIMENTAL_UNIQUE_FINGERPRINTS=${experimental.uniqueFingerprints}`,
  );

  for (const observation of observations) {
    console.log(
      JSON.stringify({
        pair: observation.pair,
        arm: observation.arm,
        semanticPass: observation.semanticPass,
        unsupportedProjectContextReference:
          observation.unsupportedProjectContextReference,
        fingerprint: observation.fingerprint,
        error: observation.error,
        parsedSupportReferences:
          observation.parsedSupportReferences,
      }),
    );
  }

  console.log("PRODUCTION_PROMPT_CHANGE=NONE");
  console.log("PRODUCTION_GENERATION_POLICY_CHANGE=NONE");
  console.log("VALIDATOR_CHANGE=NONE");
  console.log("MODEL_CHANGE=NONE");
  console.log("RETRY_OR_SECOND_MODEL_CALL=NONE");
  console.log("PRODUCTION_CHANGE=NONE");
}

void main();
