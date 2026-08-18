import {
  ollamaChat,
  type MatildaSelectedContextSegment,
  type OllamaChatContext,
} from "./utils/ollamaChat";

const VALIDATION_SEED = 424242;

const suppliedSegment = {
  relativePath: "docs/reasoning-status-behavior-validation.md",
  parentRelativePath: "docs/reasoning-status-behavior-validation.md",
  parentLineNumber: 20,
  sourceStartLine: 20,
  sourceEndLine: 20,
  text:
    "The current architecture is already established and bounded. Supporting reasoning should be classified as recommended only when skipping it is likely to materially affect the user's next engineering decision.",
};

const context: OllamaChatContext = {
  projectId: "reasoning-status-behavior-validation",
  projectDisplayName: "Reasoning Status Behavior Validation",
  projectContextExcerpts: [
    {
      relativePath: suppliedSegment.parentRelativePath,
      lineNumber: suppliedSegment.parentLineNumber,
      excerpt: suppliedSegment.text,
      provenance: "git_tracked_project_file",
      authorityStatus: "candidate_evidence_not_authority",
    },
  ],
  projectContextSegmentCandidates: [suppliedSegment],
  history: [],
  validationGenerationSeed: VALIDATION_SEED,
};

async function main() {
  let observed:
    readonly MatildaSelectedContextSegment[] | undefined;

  console.log(
    "=== PHASE 3 / CORRIDOR 2 — SINGLE SELECTED CONTEXT DIAGNOSTIC ===",
  );

  try {
    await ollamaChat(
      "Confirm whether the existing bounded implementation remains within the already-established architecture. No competing interpretation, material uncertainty, or new implementation boundary is present.",
      {
        ...context,
        observeParsedSelectedContextSegments: (segments) => {
          observed = [...segments];
          console.log(
            `PARSED_SELECTED_CONTEXT_SEGMENTS=${JSON.stringify(observed)}`,
          );
        },
      },
    );

    console.log("OLLAMA_RESULT=RETURNED_WITHOUT_MEMBERSHIP_REJECTION");
  } catch (error) {
    console.log(
      `OLLAMA_ERROR=${
        error instanceof Error ? error.message : String(error)
      }`,
    );
  }

  console.log(
    `SUPPLIED_SELECTED_CONTEXT_SEGMENTS=${JSON.stringify([
      {
        relativePath: suppliedSegment.relativePath,
        sourceStartLine: suppliedSegment.sourceStartLine,
        sourceEndLine: suppliedSegment.sourceEndLine,
      },
    ])}`,
  );
  console.log(`VALIDATION_SEED=${VALIDATION_SEED}`);
  console.log(
    "FIXED_SEED_ROLE=DIAGNOSTIC_REPEATABILITY_ONLY_NOT_PRODUCTION_POLICY",
  );
  console.log("THIRD_BEHAVIOR_VALIDATION_ATTEMPT=NOT_STARTED");
  console.log("PRODUCTION_CHANGE=NONE");
  console.log("DR_NOW=NO");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
