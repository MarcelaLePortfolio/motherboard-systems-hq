import {
  ollamaChat,
  type MatildaSelectedContextSegment,
} from "./utils/ollamaChat";

async function main() {
  const parentRelativePath =
    "docs/adaptive-detail-live-validation.md";
  const parentLineNumber = 20;

  const relevantSegment = {
    relativePath: parentRelativePath,
    parentRelativePath,
    parentLineNumber,
    sourceStartLine: 20,
    sourceEndLine: 20,
    text:
      "The selected-context validation observer is optional and absent from the normal production workflow.",
  };

  const immaterialSegment = {
    relativePath: parentRelativePath,
    parentRelativePath,
    parentLineNumber,
    sourceStartLine: 22,
    sourceEndLine: 22,
    text:
      "A future unrelated migration may redesign the dashboard color palette after the current runtime work is complete.",
  };

  const parentExcerpt =
    `${relevantSegment.text}\n\n${immaterialSegment.text}`;

  let observed:
    readonly MatildaSelectedContextSegment[] | undefined;

  let observedSupportReferences:
    readonly import("./utils/ollamaChat").MatildaSupportSourceReference[] |
    undefined;

  const result = await ollamaChat(
    "Is the selected-context validation observer used by the normal production workflow? Answer only what matters to that question.",
    {
      projectContextExcerpts: [
        {
          relativePath: parentRelativePath,
          lineNumber: parentLineNumber,
          excerpt: parentExcerpt,
          provenance:
            "git_tracked_project_file",
          authorityStatus:
            "candidate_evidence_not_authority",
        },
      ],
      projectContextSegmentCandidates: [
        relevantSegment,
        immaterialSegment,
      ],
      observeValidatedSelectedContextSegments:
        (segments) => {
          observed = [...segments];
        },
      observeParsedSupportSourceReferences:
        (references) => {
          observedSupportReferences = [...references];
          console.log(
            "PARSED SUPPORT SOURCE REFERENCES BEFORE VALIDATION",
          );
          console.log(
            JSON.stringify(
              observedSupportReferences,
              null,
              2,
            ),
          );
          console.log();
        },
    },
  );

  console.log(
    "=== ADAPTIVE DETAIL — MIXED CONTENT LIVE VALIDATION ===",
  );
  console.log();

  console.log("SELECTED CONTEXT SEGMENTS");
  console.log(
    JSON.stringify(observed ?? null, null, 2),
  );
  console.log();

  console.log("REPLY");
  console.log(result.reply);
  console.log();

  console.log("SUPPORT SOURCE REFERENCES");
  console.log(
    JSON.stringify(
      result.supportSourceReferences,
      null,
      2,
    ),
  );
  console.log();

  console.log("EVIDENCE");
  console.log(
    JSON.stringify(result.evidence, null, 2),
  );
  console.log();

  console.log("EVIDENCE SUFFICIENT");
  console.log(result.evidenceSufficient);
  console.log();

  console.log("DURABLE INTERPRETATION");
  console.log(result.durableInterpretation);
  console.log();

  if (!observed) {
    console.log(
      "ADAPTIVE_DETAIL_BEHAVIOR_VALIDATION_BLOCKED: observer was not invoked.",
    );
    process.exitCode = 2;
    return;
  }

  const relevantIdentity = {
    relativePath:
      relevantSegment.relativePath,
    sourceStartLine:
      relevantSegment.sourceStartLine,
    sourceEndLine:
      relevantSegment.sourceEndLine,
  };

  const immaterialIdentity = {
    relativePath:
      immaterialSegment.relativePath,
    sourceStartLine:
      immaterialSegment.sourceStartLine,
    sourceEndLine:
      immaterialSegment.sourceEndLine,
  };

  const hasRelevant =
    observed.some(
      (segment) =>
        segment.relativePath ===
          relevantIdentity.relativePath &&
        segment.sourceStartLine ===
          relevantIdentity.sourceStartLine &&
        segment.sourceEndLine ===
          relevantIdentity.sourceEndLine,
    );

  const hasImmaterial =
    observed.some(
      (segment) =>
        segment.relativePath ===
          immaterialIdentity.relativePath &&
        segment.sourceStartLine ===
          immaterialIdentity.sourceStartLine &&
        segment.sourceEndLine ===
          immaterialIdentity.sourceEndLine,
    );

  const replyMentionsImmaterial =
    /dashboard|color palette|migration/i.test(
      result.reply,
    );

  const parentSupportPresent =
    result.supportSourceReferences.some(
      (reference) =>
        reference.type ===
          "project_context_excerpt" &&
        reference.relativePath ===
          parentRelativePath &&
        reference.lineNumber ===
          parentLineNumber,
    );

  console.log(
    `RELEVANT_CHILD_SELECTED=${hasRelevant}`,
  );
  console.log(
    `IMMATERIAL_CHILD_SELECTED=${hasImmaterial}`,
  );
  console.log(
    `IMMATERIAL_DETAIL_IN_REPLY=${replyMentionsImmaterial}`,
  );
  console.log(
    `PARENT_SUPPORT_PRESENT=${parentSupportPresent}`,
  );

  if (
    hasRelevant &&
    !hasImmaterial &&
    !replyMentionsImmaterial &&
    parentSupportPresent
  ) {
    console.log();
    console.log(
      "ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED",
    );
    return;
  }

  console.log();

  if (!hasRelevant) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: relevant child was not selected.",
    );
  }

  if (hasImmaterial) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: immaterial child was selected.",
    );
  }

  if (replyMentionsImmaterial) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: immaterial detail surfaced in reply.",
    );
  }

  if (!parentSupportPresent) {
    console.log(
      "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED: expected parent support provenance was absent.",
    );
  }

  process.exitCode = 2;
}

main().catch((error) => {
  console.error(error);
  console.log(
    "ADAPTIVE_DETAIL_RUNTIME_REGRESSION_DETECTED",
  );
  process.exitCode = 1;
});
