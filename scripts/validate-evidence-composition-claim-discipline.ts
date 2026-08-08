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

  console.log("=== EVIDENCE COMPOSITION CLAIM DISCIPLINE ===");
  console.log();
  console.log("REPLY");
  console.log(result.reply);
  console.log();
  console.log("SUPPORT REFERENCES");
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

  const lower = result.reply.toLowerCase();

  const unsupportedPhrases = [
    "simplicity",
    "complexity",
    "speed",
    "rapid",
    "performance",
    "efficient",
    "efficiency",
    "reliable",
    "reliability",
    "system configuration",
    "current design",
    "design priority",
  ];

  const unsupported =
    unsupportedPhrases.filter(
      (phrase) => lower.includes(phrase),
    );

  const referencesProjectEvidence =
    lower.includes("workflow") &&
    (
      lower.includes("invokes") ||
      lower.includes("invocation") ||
      lower.includes("ollamachat") ||
      lower.includes("semantic seam")
    );

  if (unsupported.length > 0) {
    console.log(
      `EVIDENCE_COMPOSITION_REMAINS_OPEN: unsupported or overbroad wording detected: ${unsupported.join(", ")}`,
    );
    process.exitCode = 2;
    return;
  }

  if (!referencesProjectEvidence) {
    console.log(
      "EVIDENCE_COMPOSITION_REMAINS_OPEN: reply does not clearly present the fact established by the validated project-context evidence.",
    );
    process.exitCode = 2;
    return;
  }

  console.log(
    "EVIDENCE_COMPOSITION_BEHAVIORALLY_SUPPORTED",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
