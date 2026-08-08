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
            "turn-source-excerpt-live-validation",
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
    "=== SOURCE-EXCERPT-FIRST LIVE VALIDATION ===",
  );
  console.log();

  console.log("REPLY");
  console.log(result.reply);
  console.log();

  console.log("EVIDENCE");
  console.log(
    JSON.stringify(result.evidence, null, 2),
  );
  console.log();

  console.log("OVERALL SUPPORT REFERENCES");
  console.log(
    JSON.stringify(
      result.supportSourceReferences,
      null,
      2,
    ),
  );
  console.log();

  console.log("EVIDENCE SUFFICIENT");
  console.log(result.evidenceSufficient);
  console.log();

  console.log("=== DETERMINATION ===");

  const evidence = result.evidence;

  if (!evidence) {
    console.log(
      "SOURCE_EXCERPT_FIRST_LIVE_INCONCLUSIVE: model returned null evidence.",
    );
    process.exitCode = 2;
    return;
  }

  if (evidence.sources.length !== 1) {
    console.log(
      `SOURCE_EXCERPT_FIRST_LIVE_FAIL: expected exactly one validated evidence source, received ${evidence.sources.length}.`,
    );
    process.exitCode = 2;
    return;
  }

  const source = evidence.sources[0];

  if (
    source.reference.type !==
      "project_context_excerpt" ||
    source.reference.relativePath !==
      "server/matilda-chat-workflow.ts" ||
    source.reference.lineNumber !== 155
  ) {
    console.log(
      "SOURCE_EXCERPT_FIRST_LIVE_FAIL: evidence source identity does not match the supplied repository source.",
    );
    process.exitCode = 2;
    return;
  }

  if (source.excerpt !== suppliedExcerpt) {
    console.log(
      "SOURCE_EXCERPT_FIRST_LIVE_FAIL: evidence excerpt is not an exact reproduction of supplied source material.",
    );
    process.exitCode = 2;
    return;
  }

  console.log(
    "SOURCE_EXCERPT_FIRST_LIVE_SUPPORTED",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
