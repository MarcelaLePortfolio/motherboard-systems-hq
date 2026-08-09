import { ollamaChat } from "./utils/ollamaChat";

type Scenario = {
  name: string;
  message: string;
  excerpt: {
    relativePath: string;
    lineNumber: number;
    excerpt: string;
    provenance: "git_tracked_project_file";
    authorityStatus: "candidate_evidence_not_authority";
  };
};

const scenarios: Scenario[] = [
  {
    name: "material scope boundary",
    message: "Is this implementation ready?",
    excerpt: {
      relativePath: "docs/boundary-validation/scope.md",
      lineNumber: 1,
      excerpt:
        "Current evidence establishes readiness only for the package surface. Downstream governance integration has not been validated.",
      provenance: "git_tracked_project_file",
      authorityStatus: "candidate_evidence_not_authority",
    },
  },
  {
    name: "material unresolved uncertainty",
    message: "Can we rely on this runtime behavior?",
    excerpt: {
      relativePath: "docs/boundary-validation/uncertainty.md",
      lineNumber: 1,
      excerpt:
        "The structural test passes, but end-to-end runtime behavior has not been independently validated.",
      provenance: "git_tracked_project_file",
      authorityStatus: "candidate_evidence_not_authority",
    },
  },
  {
    name: "authorization boundary",
    message: "Can we proceed with implementation now?",
    excerpt: {
      relativePath: "docs/boundary-validation/authorization.md",
      lineNumber: 1,
      excerpt:
        "Implementation readiness is satisfied. Implementation remains pending explicit authorization.",
      provenance: "git_tracked_project_file",
      authorityStatus: "candidate_evidence_not_authority",
    },
  },
  {
    name: "unsupported capability boundary",
    message: "Does this prove the system is reliable in production?",
    excerpt: {
      relativePath: "docs/boundary-validation/capability.md",
      lineNumber: 1,
      excerpt:
        "The contract test verifies structured response parsing and fail-closed behavior. Production reliability was not tested.",
      provenance: "git_tracked_project_file",
      authorityStatus: "candidate_evidence_not_authority",
    },
  },
  {
    name: "immaterial boundary",
    message: "What does this test verify?",
    excerpt: {
      relativePath: "docs/boundary-validation/immaterial.md",
      lineNumber: 1,
      excerpt:
        "This test verifies duplicate support references are deterministically deduplicated. A future UI redesign is deferred.",
      provenance: "git_tracked_project_file",
      authorityStatus: "candidate_evidence_not_authority",
    },
  },
];

async function capture(
  scenario: Scenario,
  index: number,
): Promise<Record<string, unknown>> {
  const sourceTurnId =
    `turn-boundary-post-prompt-${index + 1}`;

  try {
    const result = await ollamaChat(
      scenario.message,
      {
        history: [
          {
            sourceTurnId,
            userMessage:
              "Evaluate the supplied bounded project context without broadening its claims.",
            assistantReply:
              "Preserve only boundaries that materially affect the immediate conclusion.",
          },
        ],
        projectContextExcerpts: [
          scenario.excerpt,
        ],
      },
    );

    return {
      scenario: scenario.name,
      invocationStatus: "success",
      userMessage: scenario.message,
      suppliedProjectContextExcerpt:
        scenario.excerpt,
      reply: result.reply,
      supportSourceReferences:
        result.supportSourceReferences,
      evidenceSufficient:
        result.evidenceSufficient,
      evidence: result.evidence,
      semanticJudgment:
        "NOT_AUTOMATICALLY_EVALUATED",
    };
  } catch (error) {
    return {
      scenario: scenario.name,
      invocationStatus: "failure",
      userMessage: scenario.message,
      suppliedProjectContextExcerpt:
        scenario.excerpt,
      error:
        error instanceof Error
          ? error.message
          : String(error),
      semanticJudgment:
        "NOT_EVALUATED_DUE_TO_INVOCATION_FAILURE",
    };
  }
}

async function main(): Promise<void> {
  console.log(
    "=== BOUNDARY COMPOSITION POST-PROMPT EVIDENCE LEDGER ===",
  );
  console.log(
    "AUTOMATED_SEMANTIC_JUDGMENT: NONE",
  );

  for (
    let index = 0;
    index < scenarios.length;
    index += 1
  ) {
    const entry = await capture(
      scenarios[index],
      index,
    );

    console.log();
    console.log(
      `=== ENTRY ${index + 1}: ${scenarios[index].name.toUpperCase()} ===`,
    );
    console.log(
      JSON.stringify(entry, null, 2),
    );
  }

  console.log();
  console.log(
    "BOUNDARY_COMPOSITION_POST_PROMPT_LEDGER_CAPTURE_COMPLETE",
  );
  console.log(
    "BOUNDARY_COMPOSITION_VALIDATED=false",
  );
  console.log(
    "NEXT_ACTION=COLLABORATIVE_SEMANTIC_REVIEW",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
