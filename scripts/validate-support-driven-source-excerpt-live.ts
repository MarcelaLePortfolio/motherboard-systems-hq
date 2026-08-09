import { ollamaChat } from "./utils/ollamaChat";

async function main() {
  const suppliedExcerpt =
    "const ollamaResult = await ollamaChat(message, {";

  const result = await ollamaChat(
    "What repository evidence shows that this workflow invokes ollamaChat?",
    {
      history: [
        {
          sourceTurnId:
            "turn-support-driven-live-validation",
          userMessage:
            "We need repository evidence for the workflow invocation seam.",
          assistantReply:
            "The repository excerpt should establish that directly.",
        },
      ],
      projectContextExcerpts: [
        {
          relativePath:
            "server/matilda-chat-workflow.ts",
          lineNumber: 155,
          excerpt: suppliedExcerpt,
          provenance:
            "git_tracked_project_file",
          authorityStatus:
            "candidate_evidence_not_authority",
        },
      ],
    },
  );

  console.log(
    "=== SUPPORT-DRIVEN SOURCE-EXCERPT LIVE VALIDATION ===",
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

  const projectSupport =
    result.supportSourceReferences.find(
      (reference) =>
        reference.type ===
          "project_context_excerpt" &&
        reference.relativePath ===
          "server/matilda-chat-workflow.ts" &&
        reference.lineNumber === 155,
    );

  if (!projectSupport) {
    console.log(
      "SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_INCONCLUSIVE: semantic invocation did not select the supplied project-context source as support.",
    );
    process.exitCode = 2;
    return;
  }

  const evidenceSource =
    result.evidence?.sources.find(
      (source) =>
        source.reference.type ===
          "project_context_excerpt" &&
        source.reference.relativePath ===
          "server/matilda-chat-workflow.ts" &&
        source.reference.lineNumber === 155,
    );

  if (!evidenceSource) {
    console.log(
      "SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_FAIL: validated project-context support did not produce Source-Excerpt evidence.",
    );
    process.exitCode = 2;
    return;
  }

  if (evidenceSource.excerpt !== suppliedExcerpt) {
    console.log(
      "SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_FAIL: runtime did not attach the exact supplied excerpt.",
    );
    process.exitCode = 2;
    return;
  }

  console.log(
    "SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_SUPPORTED",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
