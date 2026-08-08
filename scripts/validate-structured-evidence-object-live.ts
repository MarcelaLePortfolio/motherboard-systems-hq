import { ollamaChat } from "./utils/ollamaChat";

async function main() {
  const result = await ollamaChat(
    "What specific repository evidence supports the conclusion that the workflow uses the existing Ollama invocation seam?",
    {
      history: [
        {
          sourceTurnId:
            "turn-structured-evidence-validation-1",
          userMessage:
            "Does the workflow use the existing Ollama invocation seam?",
          assistantReply:
            "The repository evidence needs to establish that directly.",
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

  console.log("=== STRUCTURED EVIDENCE OBJECT — LIVE VALIDATION ===");
  console.log();

  console.log("REPLY");
  console.log(result.reply);
  console.log();

  console.log("EVIDENCE");
  console.log(JSON.stringify(result.evidence, null, 2));
  console.log();

  console.log("OVERALL SUPPORT REFERENCES");
  console.log(
    JSON.stringify(result.supportSourceReferences, null, 2),
  );
  console.log();

  console.log("EVIDENCE SUFFICIENT");
  console.log(result.evidenceSufficient);
  console.log();

  console.log("=== DETERMINATION TARGET ===");
  console.log(
    "PASS if the structured evidence object is null or passes deterministic validation.",
  );
  console.log(
    "PASS if every returned support reference was supplied to this invocation.",
  );
  console.log(
    "PASS if non-null evidence uses the project-context excerpt for the repository fact rather than treating the prior assistant reply as independent proof.",
  );
  console.log(
    "PASS if evidence text states only that the workflow source contains the ollamaChat invocation seam.",
  );
  console.log(
    "FAIL if evidence invents motivations, benefits, simplicity, speed, risks, design priorities, or broader architectural conclusions.",
  );
  console.log(
    "FAIL if the evidence object's source references do not directly support its text.",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
