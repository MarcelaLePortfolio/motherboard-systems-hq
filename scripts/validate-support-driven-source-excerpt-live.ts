import { isExplicitEvidenceRequest } from "../server/matilda-evidence-request-signal";
import { ollamaChat } from "./utils/ollamaChat";

async function main() {
  const suppliedExcerpt =
    "const ollamaResult = await ollamaChat(message, {";

  const message =
    "What repository evidence shows that this workflow invokes ollamaChat?";

  const explicitEvidenceRequest =
    isExplicitEvidenceRequest(message);

  if (!explicitEvidenceRequest) {
    console.log(
      "EXPLICIT_EVIDENCE_SIGNAL_FAIL: live validation message was not classified as an explicit evidence request.",
    );
    process.exitCode = 2;
    return;
  }

  const result = await ollamaChat(
    message,
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
      explicitEvidenceRequest,
    },
  );

  console.log(
    "=== EXPLICIT-EVIDENCE SOURCE-EXCERPT LIVE VALIDATION ===",
  );
  console.log();

  console.log("EXPLICIT EVIDENCE REQUEST");
  console.log(explicitEvidenceRequest);
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
    JSON.stringify(
      result.evidence,
      null,
      2,
    ),
  );
  console.log();

  console.log("EVIDENCE SUFFICIENT");
  console.log(result.evidenceSufficient);
  console.log();

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
      "EXPLICIT_EVIDENCE_SOURCE_EXCERPT_LIVE_FAIL: deterministic explicit-evidence admission did not surface the supplied repository excerpt.",
    );
    process.exitCode = 2;
    return;
  }

  if (
    evidenceSource.excerpt !==
    suppliedExcerpt
  ) {
    console.log(
      "EXPLICIT_EVIDENCE_SOURCE_EXCERPT_LIVE_FAIL: surfaced evidence was not the exact supplied repository excerpt.",
    );
    process.exitCode = 2;
    return;
  }

  console.log(
    "SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_SUPPORTED",
  );
  console.log(
    "EXPLICIT_EVIDENCE_SOURCE_EXCERPT_LIVE_SUPPORTED",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
