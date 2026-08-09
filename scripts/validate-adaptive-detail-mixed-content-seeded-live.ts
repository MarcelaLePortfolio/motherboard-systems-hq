import { ollamaChat } from "./utils/ollamaChat";

const VALIDATION_SEED = 424242;

async function main() {
  let selectedContextSegments:
    | readonly {
        relativePath: string;
        sourceStartLine: number;
        sourceEndLine: number;
      }[]
    | undefined;

  let parsedSupportSourceReferences:
    | readonly {
        type: string;
        relativePath?: string;
        lineNumber?: number;
        sourceTurnId?: string;
      }[]
    | undefined;

  const result = await ollamaChat(
    "Is the selected-context validation observer used by the normal production workflow? Answer only what matters to that question.",
    {
      projectId: "adaptive-detail-live-validation",
      projectDisplayName: "Adaptive Detail Live Validation",
      projectContextExcerpts: [
        {
          projectId: "adaptive-detail-live-validation",
          relativePath:
            "docs/adaptive-detail-live-validation.md",
          lineNumber: 20,
          excerpt:
            "The selected-context validation observer is optional and absent from the normal production workflow.\n\nA future unrelated migration may redesign the dashboard color palette after the current runtime work is complete.",
          provenance:
            "git_tracked_project_file",
          authorityStatus:
            "candidate_evidence_not_authority",
        },
      ],
      projectContextSegmentCandidates: [
        {
          relativePath:
            "docs/adaptive-detail-live-validation.md",
          parentRelativePath:
            "docs/adaptive-detail-live-validation.md",
          parentLineNumber: 20,
          sourceStartLine: 20,
          sourceEndLine: 20,
          text:
            "The selected-context validation observer is optional and absent from the normal production workflow.",
        },
        {
          relativePath:
            "docs/adaptive-detail-live-validation.md",
          parentRelativePath:
            "docs/adaptive-detail-live-validation.md",
          parentLineNumber: 20,
          sourceStartLine: 22,
          sourceEndLine: 22,
          text:
            "A future unrelated migration may redesign the dashboard color palette after the current runtime work is complete.",
        },
      ],
      validationGenerationSeed:
        VALIDATION_SEED,
      observeValidatedSelectedContextSegments:
        (segments) => {
          selectedContextSegments =
            segments;
        },
      observeParsedSupportSourceReferences:
        (references) => {
          parsedSupportSourceReferences =
            references;
        },
    },
  );

  const relevantSelected =
    selectedContextSegments?.some(
      (segment) =>
        segment.relativePath ===
          "docs/adaptive-detail-live-validation.md" &&
        segment.sourceStartLine === 20 &&
        segment.sourceEndLine === 20,
    ) ?? false;

  const immaterialSelected =
    selectedContextSegments?.some(
      (segment) =>
        segment.relativePath ===
          "docs/adaptive-detail-live-validation.md" &&
        segment.sourceStartLine === 22 &&
        segment.sourceEndLine === 22,
    ) ?? false;

  const invalidLine22Support =
    parsedSupportSourceReferences?.some(
      (reference) =>
        reference.type ===
          "project_context_excerpt" &&
        reference.relativePath ===
          "docs/adaptive-detail-live-validation.md" &&
        reference.lineNumber === 22,
    ) ?? false;

  const immaterialDetailInReply =
    /dashboard|color palette|migration/i.test(
      result.reply,
    );

  console.log(
    `VALIDATION_SEED=${VALIDATION_SEED}`,
  );
  console.log(
    `RELEVANT_CHILD_SELECTED=${relevantSelected}`,
  );
  console.log(
    `IMMATERIAL_CHILD_SELECTED=${immaterialSelected}`,
  );
  console.log(
    `INVALID_PARENT_LINE_22=${invalidLine22Support}`,
  );
  console.log(
    `IMMATERIAL_DETAIL_IN_REPLY=${immaterialDetailInReply}`,
  );
  console.log(
    `REPLY=${JSON.stringify(result.reply)}`,
  );
  console.log(
    `SUPPORT=${JSON.stringify(result.supportSourceReferences)}`,
  );

  if (
    relevantSelected &&
    !invalidLine22Support &&
    !immaterialDetailInReply
  ) {
    console.log(
      "SEEDED_ADAPTIVE_DETAIL_BEHAVIOR_SUPPORTED",
    );
    return;
  }

  console.log(
    "SEEDED_ADAPTIVE_DETAIL_BEHAVIOR_NOT_SUPPORTED",
  );
  process.exitCode = 2;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 2;
});
