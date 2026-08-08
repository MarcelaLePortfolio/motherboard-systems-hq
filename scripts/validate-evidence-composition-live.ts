import { ollamaChat } from "./utils/ollamaChat";

async function main() {
  const result = await ollamaChat(
    "What specific evidence supports preserving the existing workflow?",
    {
      priorExplanationEvidenceStatus: "sufficient",
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

  console.log("=== OBSERVABLE VALIDATION ===");
  console.log("[ ] Specific supporting evidence is presented.");
  console.log("[ ] Evidence is connected to the claim it supports.");
  console.log("[ ] Conversation support is described naturally.");
  console.log("[ ] Repository evidence identifies the relevant artifact naturally.");
  console.log("[ ] Internal source identifiers are not exposed.");
  console.log("[ ] Evidence is not presented as a raw source inventory.");
  console.log("[ ] No source is claimed to establish more than the supplied excerpt supports.");
  console.log("[ ] Evidence remains integrated into natural-language prose.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
