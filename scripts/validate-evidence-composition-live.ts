import { ollamaChat } from "./utils/ollamaChat";

async function main() {
  const result = await ollamaChat(
    "What specific evidence supports preserving the existing workflow?",
    {
      priorExplanationEvidenceStatus: "sufficient",
      priorExplanationSupportSourceReferences: [
        {
          type: "project_context_excerpt",
          relativePath:
            "server/matilda-chat-workflow.ts",
          lineNumber: 179,
        },
      ],
      history: [
        {
          sourceTurnId: "turn-evidence-validation-1",
          userMessage:
            "Which implementation approach should we use?",
          assistantReply:
            "I recommend preserving the existing single-invocation workflow.",
        },
      ],
      projectContextExcerpts: [
        {
          relativePath:
            "server/matilda-chat-workflow.ts",
          lineNumber: 179,
          excerpt:
            "const ollamaResult = await ollamaChat(message, {",
          provenance:
            "git_tracked_project_file",
          authorityStatus:
            "candidate_evidence_not_authority",
        },
      ],
    },
  );

  console.log("=== LIVE EVIDENCE COMPOSITION VALIDATION ===");
  console.log();

  console.log("REPLY");
  console.log(result.reply);
  console.log();

  console.log("EXPLANATION STATUS");
  console.log(result.explanationStatus);
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

  console.log("EVIDENCE SUFFICIENT");
  console.log(result.evidenceSufficient);
  console.log();

  console.log("=== VALIDATION TARGET ===");
  console.log(
    "PASS only if the reply presents what the validated prior support actually establishes.",
  );
  console.log(
    "PASS only if the reply does not invent design priorities, speed, simplicity, benefits, risks, or other unsupported rationale.",
  );
  console.log(
    "PASS if the reply explicitly says the supplied evidence is narrower than the broader recommendation when appropriate.",
  );
  console.log(
    "PASS if the validated project-context evidence is used instead of treating the prior assistant recommendation as proof of itself.",
  );
  console.log(
    "PASS if internal source identifiers and raw provenance metadata remain hidden.",
  );
  console.log(
    "PASS if the evidence remains integrated into natural-language prose.",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
