import { ollamaChat } from "./utils/ollamaChat";

async function main() {
  const result = await ollamaChat(
    "Why do you recommend preserving the existing workflow?",
    {
      priorExplanationEvidenceStatus: "sufficient",
      history: [
        {
          sourceTurnId: "turn-reasoning-validation-1",
          userMessage:
            "Which implementation approach should we use?",
          assistantReply:
            "I recommend preserving the existing single-invocation workflow because changing that boundary would introduce unnecessary architectural risk.",
        },
      ],
      projectContextExcerpts: [
        {
          relativePath: "server/matilda-chat-workflow.ts",
          lineNumber: 179,
          excerpt:
            "const ollamaResult = await ollamaChat(message, {",
          provenance: "git_tracked_project_file",
          authorityStatus:
            "candidate_evidence_not_authority",
        },
      ],
    },
  );

  console.log("=== LIVE REASONING COMPOSITION VALIDATION ===");
  console.log();
  console.log("REPLY");
  console.log(result.reply);
  console.log();
  console.log("EXPLANATION STATUS");
  console.log(result.explanationStatus);
  console.log();
  console.log("SUPPORT SOURCE REFERENCES");
  console.log(
    JSON.stringify(result.supportSourceReferences, null, 2),
  );
  console.log();
  console.log("EVIDENCE SUFFICIENT");
  console.log(result.evidenceSufficient);
  console.log();
  console.log("=== OBSERVABLE VALIDATION ===");
  console.log("[ ] Prior recommendation is clearly restated.");
  console.log("[ ] Governing rationale is user-visible.");
  console.log("[ ] Tradeoffs appear only if relevant.");
  console.log("[ ] Uncertainty appears only if supported.");
  console.log("[ ] No hidden reasoning or chain-of-thought.");
  console.log("[ ] Natural prose (not mechanical headings).");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
