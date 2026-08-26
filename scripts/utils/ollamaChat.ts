const OLLAMA_BASE_URL =
  process.env.OLLAMA_BASE_URL ?? "http://localhost:11434";

const OLLAMA_CHAT_MODEL =
  process.env.OLLAMA_CHAT_MODEL ?? "gemma3:4b";

const OLLAMA_CHAT_TIMEOUT_MS = Number(
  process.env.OLLAMA_CHAT_TIMEOUT_MS ?? 90_000,
);

interface OllamaGenerateResponse {
  response?: string;
}

interface OllamaStructuredResponse {
  reply?: unknown;
  explanationStatus?: unknown;
  selectedContextSegments?: unknown;
  supportSourceReferences?: unknown;
  evidence?: unknown;
  investigationLifecycle?: unknown;
  packageSemantics?: unknown;
  durableInterpretation?: unknown;
}

const OLLAMA_CHAT_OUTPUT_SCHEMA = {
  type: "object",
  additionalProperties: false,
  required: [
    "reply",
    "explanationStatus",
    "selectedContextSegments",
    "supportSourceReferences",
    "evidence",
    "investigationLifecycle",
    "packageSemantics",
    "durableInterpretation",
  ],
  properties: {
    reply: {
      type: "string",
    },
    explanationStatus: {
      type: "string",
      enum: ["optional", "recommended"],
    },
    selectedContextSegments: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "relativePath",
          "sourceStartLine",
          "sourceEndLine",
        ],
        properties: {
          relativePath: {
            type: "string",
          },
          sourceStartLine: {
            type: "integer",
            minimum: 1,
          },
          sourceEndLine: {
            type: "integer",
            minimum: 1,
          },
        },
      },
    },
    supportSourceReferences: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["type"],
        properties: {
          type: {
            type: "string",
            enum: [
              "conversation_turn",
              "project_context_excerpt",
            ],
          },
          sourceTurnId: {
            type: "string",
          },
          relativePath: {
            type: "string",
          },
          lineNumber: {
            type: "integer",
            minimum: 1,
          },
        },
      },
    },
    evidence: {
      anyOf: [
        {
          type: "null",
        },
        {
          type: "object",
          additionalProperties: false,
          required: ["sources"],
          properties: {
            sources: {
              type: "array",
              items: {
                type: "object",
                additionalProperties: false,
                required: ["reference"],
                properties: {
                  reference: {
                    type: "object",
                    additionalProperties: false,
                    required: [
                      "type",
                      "relativePath",
                      "lineNumber",
                    ],
                    properties: {
                      type: {
                        type: "string",
                        enum: ["project_context_excerpt"],
                      },
                      relativePath: {
                        type: "string",
                      },
                      lineNumber: {
                        type: "integer",
                        minimum: 1,
                      },
                    },
                  },
                },
              },
            },
          },
        },
      ],
    },
    investigationLifecycle: {
      anyOf: [
        {
          type: "null",
        },
        {
          type: "object",
          additionalProperties: false,
          required: [
            "investigationIdentity",
            "governingQuestion",
            "lifecycleEvent",
            "lifecycleDetermination",
          ],
          properties: {
            investigationIdentity: {
              type: "string",
            },
            governingQuestion: {
              type: "string",
            },
            lifecycleEvent: {
              type: "string",
              enum: [
                "entered",
                "continued",
                "advanced",
                "resolved",
                "superseded",
                "abandoned",
              ],
            },
            lifecycleDetermination: {
              anyOf: [
                {
                  type: "null",
                },
                {
                  type: "string",
                },
              ],
            },
          },
        },
      ],
    },
    packageSemantics: {
      anyOf: [
        {
          type: "null",
        },
        {
          type: "object",
          additionalProperties: false,
          required: [
            "expectedOutcome",
            "proposedWork",
            "proposedArtifacts",
            "inScope",
            "outOfScope",
            "constraints",
            "unresolvedQuestions",
          ],
          properties: {
            expectedOutcome: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            proposedWork: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            proposedArtifacts: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            inScope: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            outOfScope: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            constraints: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            unresolvedQuestions: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
          },
        },
      ],
    },
    durableInterpretation: {
      type: "string",
    },
  },
} as const;

export interface OllamaChatHistoryTurn {
  sourceTurnId?: string;
  userMessage: string;
  assistantReply: string;
}

export interface MatildaSupportSourceReference {
  type: "conversation_turn" | "project_context_excerpt";
  sourceTurnId?: string;
  relativePath?: string;
  lineNumber?: number;
}

export interface OllamaChatProjectContextExcerpt {
  relativePath: string;
  lineNumber: number;
  excerpt: string;
  provenance: "git_tracked_project_file";
  authorityStatus: "candidate_evidence_not_authority";
}

export interface OllamaChatProjectContextSegmentCandidate {
  relativePath: string;
  parentRelativePath: string;
  parentLineNumber: number;
  sourceStartLine: number;
  sourceEndLine: number;
  text: string;
}

export type MatildaPriorExplanationEvidenceStatus =
  | "sufficient"
  | "insufficient"
  | "unavailable";

export interface OllamaChatContext {
  projectId?: string | null;
  projectDisplayName?: string | null;
  history?: OllamaChatHistoryTurn[];
  projectContextExcerpts?: OllamaChatProjectContextExcerpt[];
  projectContextSegmentCandidates?:
    OllamaChatProjectContextSegmentCandidate[];
  projectContextWarning?: string | null;
  priorExplanationEvidenceStatus?:
    MatildaPriorExplanationEvidenceStatus;
  priorInvestigationLifecycle?:
    MatildaInvestigationLifecycleArtifact | null;
  explicitEvidenceRequest?: boolean;
  observeValidatedSelectedContextSegments?: (
    segments: readonly MatildaSelectedContextSegment[],
  ) => void;
  observeParsedSelectedContextSegments?: (
    segments: readonly MatildaSelectedContextSegment[],
  ) => void;
  validationGenerationSeed?: number;
  validationPromptPresentationVariant?:
    | "explicit_parent_child_separation";
  observeParsedSupportSourceReferences?: (
    references: readonly MatildaSupportSourceReference[],
  ) => void;
}

export type MatildaExplanationStatus =
  | "optional"
  | "recommended";

export interface MatildaEvidenceArtifact {
  sources: Array<{
    reference: MatildaSupportSourceReference;
    excerpt: string;
  }>;
}

export interface OllamaChatResult {
  reply: string;
  explanationStatus: MatildaExplanationStatus;
  supportSourceReferences: MatildaSupportSourceReference[];
  evidence: MatildaEvidenceArtifact | null;
  evidenceSufficient: boolean;
  investigationLifecycle: MatildaInvestigationLifecycleArtifact | null;
  packageSemantics: MatildaPackageSemanticsArtifact | null;
  durableInterpretation: string;
}

export interface MatildaPackageSemanticsArtifact {
  expectedOutcome: string | null;
  proposedWork: string | null;
  proposedArtifacts: string | null;
  inScope: string | null;
  outOfScope: string | null;
  constraints: string | null;
  unresolvedQuestions: string | null;
}

export type MatildaInvestigationLifecycleEvent =
  | "entered"
  | "continued"
  | "advanced"
  | "resolved"
  | "superseded"
  | "abandoned";

export interface MatildaInvestigationLifecycleArtifact {
  investigationIdentity: string;
  governingQuestion: string;
  lifecycleEvent: MatildaInvestigationLifecycleEvent;
  lifecycleDetermination: string | null;
}

export interface MatildaSelectedContextSegment {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
}

type ParsedOllamaChatResult =
  Omit<OllamaChatResult, "evidenceSufficient"> & {
    selectedContextSegments: MatildaSelectedContextSegment[];
  };

export function validateMatildaPackageSemanticsArtifact(
  value: unknown,
  errorPrefix = "Ollama returned",
): MatildaPackageSemanticsArtifact {
  if (
    !value ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    throw new Error(
      `${errorPrefix} malformed package semantics artifact.`,
    );
  }

  const candidate = value as Record<string, unknown>;

  const fields = [
    "expectedOutcome",
    "proposedWork",
    "proposedArtifacts",
    "inScope",
    "outOfScope",
    "constraints",
    "unresolvedQuestions",
  ] as const;

  const validated: MatildaPackageSemanticsArtifact = {
    expectedOutcome: null,
    proposedWork: null,
    proposedArtifacts: null,
    inScope: null,
    outOfScope: null,
    constraints: null,
    unresolvedQuestions: null,
  };

  for (const field of fields) {
    const rawValue = candidate[field];

    if (rawValue === null) {
      validated[field] = null;
      continue;
    }

    if (typeof rawValue !== "string") {
      throw new Error(
        `${errorPrefix} malformed package semantics field ${field}.`,
      );
    }

    const trimmedValue = rawValue.trim();

    if (!trimmedValue) {
      throw new Error(
        `${errorPrefix} empty package semantics field ${field}.`,
      );
    }

    validated[field] = trimmedValue;
  }

  return validated;
}

export function validateMatildaInvestigationLifecycleArtifact(
  value: unknown,
  errorPrefix = "Ollama returned",
): MatildaInvestigationLifecycleArtifact {
  if (
    !value ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    throw new Error(
      `${errorPrefix} malformed investigation lifecycle artifact.`,
    );
  }

  const candidate = value as Record<string, unknown>;

  const investigationIdentity =
    typeof candidate.investigationIdentity === "string"
      ? candidate.investigationIdentity.trim()
      : "";

  const governingQuestion =
    typeof candidate.governingQuestion === "string"
      ? candidate.governingQuestion.trim()
      : "";

  const lifecycleEvent = candidate.lifecycleEvent;

  const validLifecycleEvents =
    new Set<MatildaInvestigationLifecycleEvent>([
      "entered",
      "continued",
      "advanced",
      "resolved",
      "superseded",
      "abandoned",
    ]);

  if (!investigationIdentity) {
    throw new Error(
      `${errorPrefix} investigation lifecycle without investigation identity.`,
    );
  }

  if (!governingQuestion) {
    throw new Error(
      `${errorPrefix} investigation lifecycle without governing question.`,
    );
  }

  if (
    typeof lifecycleEvent !== "string" ||
    !validLifecycleEvents.has(
      lifecycleEvent as MatildaInvestigationLifecycleEvent,
    )
  ) {
    throw new Error(
      `${errorPrefix} invalid investigation lifecycle event.`,
    );
  }

  let lifecycleDetermination: string | null = null;

  if (candidate.lifecycleDetermination !== null) {
    if (typeof candidate.lifecycleDetermination !== "string") {
      throw new Error(
        `${errorPrefix} malformed investigation lifecycle determination.`,
      );
    }

    lifecycleDetermination =
      candidate.lifecycleDetermination.trim();

    if (!lifecycleDetermination) {
      throw new Error(
        `${errorPrefix} empty investigation lifecycle determination.`,
      );
    }
  }

  if (
    (lifecycleEvent === "advanced" ||
      lifecycleEvent === "resolved") &&
    !lifecycleDetermination
  ) {
    throw new Error(
      `${errorPrefix} ${lifecycleEvent} investigation lifecycle without required determination.`,
    );
  }

  return {
    investigationIdentity,
    governingQuestion,
    lifecycleEvent:
      lifecycleEvent as MatildaInvestigationLifecycleEvent,
    lifecycleDetermination,
  };
}

export function validateMatildaInvestigationLifecycleContinuity(
  priorInvestigationLifecycle:
    MatildaInvestigationLifecycleArtifact | null,
  currentInvestigationLifecycle:
    MatildaInvestigationLifecycleArtifact | null,
): void {
  if (
    !priorInvestigationLifecycle ||
    !currentInvestigationLifecycle
  ) {
    return;
  }

  if (
    currentInvestigationLifecycle.lifecycleEvent !==
      "continued" &&
    currentInvestigationLifecycle.lifecycleEvent !==
      "advanced"
  ) {
    return;
  }

  if (
    currentInvestigationLifecycle.investigationIdentity !==
    priorInvestigationLifecycle.investigationIdentity
  ) {
    throw new Error(
      `Ollama returned ${currentInvestigationLifecycle.lifecycleEvent} investigation lifecycle with investigation identity that does not match prior lifecycle context.`,
    );
  }
}

function parseStructuredResponse(
  rawResponse: string,
): ParsedOllamaChatResult {
  let parsed: OllamaStructuredResponse;

  try {
    parsed = JSON.parse(
      rawResponse,
    ) as OllamaStructuredResponse;
  } catch {
    throw new Error(
      "Ollama returned malformed structured response JSON.",
    );
  }

  if (
    !parsed ||
    typeof parsed !== "object" ||
    Array.isArray(parsed)
  ) {
    throw new Error(
      "Ollama returned an invalid structured response.",
    );
  }

  const reply =
    typeof parsed.reply === "string"
      ? parsed.reply.trim()
      : "";

  const explanationStatus =
    parsed.explanationStatus === "optional" ||
    parsed.explanationStatus === "recommended"
      ? parsed.explanationStatus
      : null;

  const rawSelectedContextSegments =
    Array.isArray(parsed.selectedContextSegments)
      ? parsed.selectedContextSegments
      : null;

  const selectedContextSegments: MatildaSelectedContextSegment[] = [];

  if (rawSelectedContextSegments) {
    for (const segment of rawSelectedContextSegments) {
      if (
        !segment ||
        typeof segment !== "object" ||
        Array.isArray(segment)
      ) {
        throw new Error(
          "Ollama returned malformed selected context segment.",
        );
      }

      const candidate = segment as Record<string, unknown>;

      if (
        typeof candidate.relativePath !== "string" ||
        !candidate.relativePath.trim() ||
        typeof candidate.sourceStartLine !== "number" ||
        !Number.isInteger(candidate.sourceStartLine) ||
        candidate.sourceStartLine < 1 ||
        typeof candidate.sourceEndLine !== "number" ||
        !Number.isInteger(candidate.sourceEndLine) ||
        candidate.sourceEndLine < candidate.sourceStartLine
      ) {
        throw new Error(
          "Ollama returned malformed selected context segment.",
        );
      }

      selectedContextSegments.push({
        relativePath: candidate.relativePath.trim(),
        sourceStartLine: candidate.sourceStartLine,
        sourceEndLine: candidate.sourceEndLine,
      });
    }
  }

  const rawSupportSourceReferences =
    Array.isArray(parsed.supportSourceReferences)
      ? parsed.supportSourceReferences
      : null;

  const supportSourceReferences:
    MatildaSupportSourceReference[] = [];

  let evidence: MatildaEvidenceArtifact | null = null;

  if (parsed.evidence !== null) {
    if (
      !parsed.evidence ||
      typeof parsed.evidence !== "object" ||
      Array.isArray(parsed.evidence)
    ) {
      throw new Error(
        "Ollama returned malformed evidence artifact.",
      );
    }

    const rawEvidence =
      parsed.evidence as Record<string, unknown>;

    if (!Array.isArray(rawEvidence.sources)) {
      throw new Error(
        "Ollama returned malformed evidence sources.",
      );
    }

    const sources: MatildaEvidenceArtifact["sources"] = [];

    for (const source of rawEvidence.sources) {
      if (
        !source ||
        typeof source !== "object" ||
        Array.isArray(source)
      ) {
        throw new Error(
          "Ollama returned malformed evidence source.",
        );
      }

      const candidate =
        source as Record<string, unknown>;

      if (
        !candidate.reference ||
        typeof candidate.reference !== "object" ||
        Array.isArray(candidate.reference)
      ) {
        throw new Error(
          "Ollama returned malformed evidence source.",
        );
      }

      const reference =
        candidate.reference as Record<string, unknown>;

      if (
        reference.type !== "project_context_excerpt" ||
        typeof reference.relativePath !== "string" ||
        !reference.relativePath.trim() ||
        typeof reference.lineNumber !== "number" ||
        !Number.isInteger(reference.lineNumber) ||
        reference.lineNumber < 1
      ) {
        throw new Error(
          "Ollama returned malformed evidence project-context source.",
        );
      }

      sources.push({
        reference: {
          type: "project_context_excerpt",
          relativePath: reference.relativePath.trim(),
          lineNumber: reference.lineNumber,
        },
        excerpt: "",
      });
    }

    evidence = { sources };
  }

  if (rawSupportSourceReferences) {
    for (const reference of rawSupportSourceReferences) {
      if (
        !reference ||
        typeof reference !== "object" ||
        Array.isArray(reference)
      ) {
        throw new Error(
          "Ollama returned malformed support source reference.",
        );
      }

      const candidate =
        reference as Record<string, unknown>;

      if (candidate.type === "conversation_turn") {
        if (
          typeof candidate.sourceTurnId !== "string" ||
          !candidate.sourceTurnId.trim()
        ) {
          throw new Error(
            "Ollama returned malformed conversation support reference.",
          );
        }

        supportSourceReferences.push({
          type: "conversation_turn",
          sourceTurnId: candidate.sourceTurnId.trim(),
        });

        continue;
      }

      if (candidate.type === "project_context_excerpt") {
        if (
          typeof candidate.relativePath !== "string" ||
          !candidate.relativePath.trim() ||
          typeof candidate.lineNumber !== "number" ||
          !Number.isInteger(candidate.lineNumber) ||
          candidate.lineNumber < 1
        ) {
          throw new Error(
            "Ollama returned malformed project-context support reference.",
          );
        }

        supportSourceReferences.push({
          type: "project_context_excerpt",
          relativePath: candidate.relativePath.trim(),
          lineNumber: candidate.lineNumber,
        });

        continue;
      }

      throw new Error(
        "Ollama returned unknown support source reference type.",
      );
    }
  }

  if (!("investigationLifecycle" in parsed)) {
    throw new Error(
      "Ollama returned structured response without investigation lifecycle.",
    );
  }

  if (!("packageSemantics" in parsed)) {
    throw new Error(
      "Ollama returned structured response without package semantics.",
    );
  }

  let investigationLifecycle: MatildaInvestigationLifecycleArtifact | null =
    null;

  if (parsed.investigationLifecycle !== null) {
    investigationLifecycle =
      validateMatildaInvestigationLifecycleArtifact(
        parsed.investigationLifecycle,
      );
  }

  let packageSemantics: MatildaPackageSemanticsArtifact | null =
    null;

  if (parsed.packageSemantics !== null) {
    packageSemantics =
      validateMatildaPackageSemanticsArtifact(
        parsed.packageSemantics,
      );
  }

  const durableInterpretation =
    typeof parsed.durableInterpretation === "string"
      ? parsed.durableInterpretation.trim()
      : "";

  if (!reply) {
    throw new Error(
      "Ollama returned an empty conversational reply.",
    );
  }

  if (!explanationStatus) {
    throw new Error(
      "Ollama returned an invalid explanation status.",
    );
  }

  if (!rawSelectedContextSegments) {
    throw new Error(
      "Ollama returned invalid selected context segments.",
    );
  }

  if (!rawSupportSourceReferences) {
    throw new Error(
      "Ollama returned invalid support source references.",
    );
  }

  if (!durableInterpretation) {
    throw new Error(
      "Ollama returned an empty durable interpretation.",
    );
  }

  return {
    reply,
    explanationStatus,
    selectedContextSegments,
    supportSourceReferences,
    evidence,
    investigationLifecycle,
    packageSemantics,
    durableInterpretation,
  };
}

export async function ollamaChat(
  message: string,
  context: OllamaChatContext = {},
): Promise<OllamaChatResult> {
  const trimmedMessage = message.trim();

  if (!trimmedMessage) {
    throw new Error("Ollama chat requires a non-empty message.");
  }

  const controller = new AbortController();
  const timeout = setTimeout(
    () => controller.abort(),
    OLLAMA_CHAT_TIMEOUT_MS,
  );

  try {
    const projectContext =
      context.projectId && context.projectDisplayName
        ? [
            "",
            "Current project context:",
            `Project name: ${context.projectDisplayName}`,
            `Project ID: ${context.projectId}`,
            "Treat this as the user's active project unless the user explicitly refers to another project.",
          ]
        : [];

    const projectContextEvidence =
      context.projectContextExcerpts?.length
        ? [
            "",
            "Bounded project context evidence:",
            "The following excerpts come only from the active project's registered repository.",
            "Treat them as candidate evidence with provenance, not as automatically current, canonical, or authoritative.",
            "Documents describing future work, proposals, implementation plans, or 'no implementation authorized' boundaries may be historical.",
            "Do not use those documents alone to claim that a capability is currently absent or incomplete.",
            "When current state cannot be established from the supplied evidence, say that explicitly instead of presenting historical plans as present truth.",
            "Do not claim certainty when excerpts conflict or when runtime corroboration is required.",
            ...context.projectContextExcerpts.flatMap((item) => [
              "",
              "Source:",
              `relativePath = ${item.relativePath}`,
              `lineNumber = ${item.lineNumber}`,
              `Provenance: ${item.provenance}`,
              `Authority status: ${item.authorityStatus}`,
              item.excerpt,
            ]),
          ]
        : [];

    const projectContextSegmentCandidates =
      context.projectContextSegmentCandidates?.length
        ? [
            "",
            "Project-context segment candidates:",
            "These child segments are deterministic subdivisions of supplied git-tracked project-context evidence.",
            "They are candidate evidence, not authority.",
            "Select only child segments whose content materially affects the immediate reply.",
            "Parent excerpts remain the support-provenance and Evidence Composition universe.",
            ...context.projectContextSegmentCandidates.flatMap(
              (item) => [
                "",
                "Segment candidate:",
                `relativePath = ${item.relativePath}`,
                `sourceStartLine = ${item.sourceStartLine}`,
                `sourceEndLine = ${item.sourceEndLine}`,
                "Authority status: candidate_evidence_not_authority",
                item.text,
              ],
            ),
          ]
        : [];

    const projectContextWarning = context.projectContextWarning
      ? [
          "",
          "Project context retrieval notice:",
          context.projectContextWarning,
          "Do not substitute context from another project.",
        ]
      : [];

    const conversationHistory = (context.history || []).flatMap(
      (turn) => [
        "",
        ...(turn.sourceTurnId
          ? [`Conversation source: ${turn.sourceTurnId}`]
          : []),
        `User: ${turn.userMessage}`,
        `Matilda: ${turn.assistantReply}`,
      ],
    );

    const priorInvestigationLifecycleContext =
      context.priorInvestigationLifecycle
        ? [
            "",
            "Prior Matilda-authored Investigation Lifecycle state:",
            JSON.stringify(
              context.priorInvestigationLifecycle,
            ),
            "Treat this as previously authored semantic state for continuity context only.",
            "Do not treat its lifecycleEvent as the required current lifecycleEvent.",
            "Determine the current investigationLifecycle from the current user message and supplied context.",
          ]
        : [];

    const priorExplanationEvidence =
      context.priorExplanationEvidenceStatus
        ? [
            "",
            "Deterministic prior-conclusion evidence status:",
            `Evidence status: ${context.priorExplanationEvidenceStatus}`,
            context.priorExplanationEvidenceStatus === "sufficient"
              ? "The immediately preceding eligible conclusion has persisted validated support provenance. A requested explanation may be provided, but it must remain grounded in supplied context and must not invent additional justification."
              : "The immediately preceding eligible conclusion does not have persisted validated support provenance available for justification. If the current user explicitly requests an explanation of that prior conclusion, do not invent an engineering justification. State that sufficient supporting justification is not available from the established evidence.",
          ]
        : [];

    const validationPromptPresentation =
      context.validationPromptPresentationVariant === undefined ||
      context.validationPromptPresentationVariant ===
        "explicit_parent_child_separation"
        ? [
            "",
            "Validation-only project-context identity presentation:",
            "Support provenance identities and semantic child-selection identities are separate domains.",
            "",
            "Parent support-provenance identities:",
            ...(context.projectContextExcerpts || []).flatMap((item) => [
              "Parent support source:",
              `relativePath = ${item.relativePath}`,
              `lineNumber = ${item.lineNumber}`,
            ]),
            "",
            "Child semantic-selection identities:",
            ...(context.projectContextSegmentCandidates || []).flatMap(
              (item) => [
                `Child selection source = ${item.relativePath}:${item.sourceStartLine}:${item.sourceEndLine}`,
                `Child parent support source = ${item.parentRelativePath}:${item.parentLineNumber}`,
              ],
            ),
            "",
            "When a selected child supports the reply, selectedContextSegments must use the exact child selection identity.",
            "supportSourceReferences must use only the corresponding exact parent support source identity.",
            "Never copy a child sourceStartLine or sourceEndLine into a project_context_excerpt support reference.",
            "This validation-only presentation does not change the semantic contract or the allowed source identities.",
          ]
        : [];

    const response = await fetch(
      `${OLLAMA_BASE_URL}/api/generate`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        signal: controller.signal,
        body: JSON.stringify({
          model: OLLAMA_CHAT_MODEL,
          stream: false,
          format: OLLAMA_CHAT_OUTPUT_SCHEMA,
          ...(context.validationGenerationSeed === undefined
            ? {}
            : {
                options: {
                  seed: context.validationGenerationSeed,
                },
              }),
          prompt: [
            "You are Matilda, a natural and thoughtful collaborative assistant",
            "operating inside Motherboard Systems HQ.",
            "",
            "Return exactly one JSON object matching the supplied schema.",
            "Set reply to the natural-language response shown directly to the user.",
            "Set selectedContextSegments to exactly the supplied project-context child segments whose content materially affects the immediate reply.",
            "Use only the exact relativePath, sourceStartLine, and sourceEndLine supplied for each selected child.",
            "Do not select a child merely because it was supplied.",
            "Return [] when no supplied project-context child materially affects the immediate reply.",
            "Conversation history remains independent and does not require selectedContextSegments membership.",
            "Set supportSourceReferences to only the supplied conversation turns or parent project-context excerpts that explicitly support the conclusion, recommendation, or assessment expressed in reply.",
            "selectedContextSegments records semantic project-context admission; supportSourceReferences records support provenance.",
            "For conversation support, use type conversation_turn with the exact Conversation source identifier supplied in history.",
            "For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied in bounded project context evidence.",
            "For project_context_excerpt support, copy relativePath from the explicit relativePath field only and copy lineNumber from the explicit lineNumber field only.",
            "The relativePath field must contain only the raw repository path and must never include a colon-line suffix such as :12.",
            "A Display identity such as path/to/file.ts:12 is human-readable only and must never be copied wholesale into relativePath.",
            "For project_context_excerpt support, use only a Source identity explicitly shown under Bounded project context evidence.",
            "Never use a Segment source line range, sourceStartLine, sourceEndLine, or child segment line number as a project_context_excerpt support identity.",
            "Do not invent, reconstruct, approximate, or reference a source identifier that was not supplied in this invocation.",
            "Return an empty supportSourceReferences array when no supplied source explicitly supports the conclusion, recommendation, or assessment.",
            "supportSourceReferences records support provenance only. Do not use it for reasoning text, confidence, correctness, or Explanation Status.",
            ...validationPromptPresentation,
            "Set investigationLifecycle to null when the current response does not semantically enter, continue, advance, resolve, supersede, or abandon an investigation.",
            "Otherwise set investigationLifecycle to one bounded semantic artifact containing investigationIdentity, governingQuestion, lifecycleEvent, and lifecycleDetermination.",
            "Use lifecycleEvent only as entered, continued, advanced, resolved, superseded, or abandoned.",
            "For advanced and resolved, lifecycleDetermination must state the material investigative determination and must not be null.",
            "For entered, continued, superseded, and abandoned, lifecycleDetermination may be null when no separate material determination is required.",
            "Do not invent investigation progress unsupported by the conversation.",
            "Do not use conversation identifiers or interpretation-entry identifiers as investigationIdentity merely because those identifiers exist.",
            "Set packageSemantics to null only when the current turn establishes no request-specific structured package semantics.",
            "Otherwise set packageSemantics to one atomic non-authoritative artifact describing the user's requested outcome, proposed work, proposed artifacts, scope, constraints, and unresolved questions.",
            "For expectedOutcome, proposedWork, proposedArtifacts, inScope, outOfScope, constraints, and unresolvedQuestions, use a concise non-empty string only when that semantic is actually established; otherwise use null.",
            "When the current user request explicitly establishes any package-semantic field, preserve that request-specific information in the corresponding non-null packageSemantics field instead of returning null for that field.",
            "A package-semantics field may remain null when the current request does not establish that information. Do not invent unsupported package semantics merely to fill a nullable field.",
            "Do not use generic Living Draft process language as package semantics.",
            "Do not invent scope, deliverables, constraints, outcomes, or unresolved questions.",
            "Set durableInterpretation to a concise durable account of the user's meaning, intent, decisions, constraints, and unresolved questions.",
            "The two fields must be independently authored and must not be identical unless their meanings genuinely require identical wording.",
            "",
            "For explanationStatus:",
            "Set explanationStatus to optional by default.",
            "Set explanationStatus to recommended only when skipping supporting reasoning is likely to materially affect the user's next engineering decision.",
            "Relevant triggers may include architectural nuance, implementation boundaries, significant uncertainty, competing interpretations, or evidence interpretation when they materially affect the conclusion.",
            "Do not set explanationStatus to recommended merely because evidence exists, the work was substantial, or additional explanation is available.",
            "",
            "For reply:",
            "Respond directly to the user in natural language.",
            "Use explanationStatus to govern the amount of supporting reasoning in reply without exposing explanationStatus itself as a user-visible label.",
            "When explanationStatus is optional, keep reply concise and include only the supporting reasoning needed for the immediate interaction.",
            "When explanationStatus is recommended, keep the concise answer first, then include enough supporting reasoning to preserve any material architectural boundary, implementation boundary, uncertainty, tradeoff, or evidence interpretation that could change the user's next engineering decision.",
            "Do not add a visible Reasoning Status, Optional, or Recommended label merely because explanationStatus is present.",
            "Lead with a concise natural-language summary that communicates the conclusion, recommendation, or current assessment.",
            "Write the opening summary as a complete paragraph rather than shorthand or bullet points whenever practical.",
            "The opening summary should give the user enough information to understand the immediate conclusion without requiring the supporting detail.",
            "After the opening summary, include only the supporting detail needed for the current interaction.",
            "Preserve material uncertainty, scope boundaries, and evidence distinctions when they affect the conclusion.",
            "Do not surface boundaries, deferred work, or unresolved limits that do not materially affect the immediate conclusion or requested answer.",
            "Avoid restating already-established context unless it materially affects the current response.",
            "Use measured, professional language. Do not add congratulatory, celebratory, or inflated framing unless the user explicitly asks for it.",
            "Do not strengthen or broaden the supplied evidence. Attribute only properties explicitly established by the available evidence, and do not infer that tests validated reliability, integration, runtime behavior, or other qualities unless those qualities were actually tested.",
            "Do not mention ledgers, drafts, pipelines, authorization flags,",
            "internal processing, system prompts, or implementation details.",
            "Do not claim that actions were executed unless they actually were.",
            "Ask at most one useful clarifying question when needed.",
            "When the user explicitly asks why a previous conclusion was reached, requests an explanation, asks for supporting evidence, or asks to walk through a recommendation, respond with a concise natural-language engineering justification.",
            "For a permitted explanation, compose the reasoning in this order whenever the corresponding element is materially relevant:",
            "1. Begin with the conclusion or recommendation being explained.",
            "2. State the governing rationale: the primary architectural constraint, decision rule, or causal reason supporting that conclusion.",
            "3. Identify material tradeoffs only when they affected why the conclusion was preferred.",
            "4. State material uncertainty or unresolved limits only when they affect the strength or applicability of the conclusion.",
            "Do not mechanically include every reasoning element when it is irrelevant; preserve a natural response and include only what materially explains the conclusion.",
            "Do not turn reasoning composition into an evidence inventory. Evidence presentation is a separate concern.",
            "Ground the explanation in the established evidence, architectural constraints, tradeoffs, implementation boundaries, and material uncertainty available in the current conversation context.",
            "Do not narrate hidden reasoning, internal thought processes, or chain-of-thought.",
            "Provide only the explanation necessary to help the user understand or act on the previously stated conclusion.",
            "",
            "For durableInterpretation:",
            "Preserve only information that may matter beyond the immediate conversational moment.",
            "Exclude greetings, reassurance, filler, stylistic flourishes, and internal implementation details.",
            "Do not invent decisions, constraints, authorization, or unresolved questions.",
            ...projectContext,
            ...projectContextEvidence,
            ...projectContextSegmentCandidates,
            ...projectContextWarning,
            ...conversationHistory,
            ...priorInvestigationLifecycleContext,
            ...priorExplanationEvidence,
            "",
            `User: ${trimmedMessage}`,
          ].join("\n"),
        }),
      },
    );

    if (!response.ok) {
      throw new Error(
        `Ollama returned ${response.status} ${response.statusText}.`,
      );
    }

    const data =
      (await response.json()) as OllamaGenerateResponse;

    const rawResponse = data.response?.trim();

    if (!rawResponse) {
      throw new Error("Ollama returned an empty response.");
    }

    const result =
      parseStructuredResponse(rawResponse);

    if (context.observeParsedSelectedContextSegments) {
      context.observeParsedSelectedContextSegments(
        result.selectedContextSegments,
      );
    }

    validateMatildaInvestigationLifecycleContinuity(
      context.priorInvestigationLifecycle ?? null,
      result.investigationLifecycle,
    );

    const suppliedSegmentCandidates =
      context.projectContextSegmentCandidates || [];

    const suppliedSegmentByIdentity = new Map(
      suppliedSegmentCandidates.map((segment) => [
        `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
        segment,
      ]),
    );

    const deduplicatedSelectedContextSegments =
      result.selectedContextSegments.filter(
        (segment, index, segments) => {
          const identity =
            `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`;

          return segments.findIndex(
            (candidate) =>
              `${candidate.relativePath}:${candidate.sourceStartLine}:${candidate.sourceEndLine}` ===
              identity,
          ) === index;
        },
      );

    for (const segment of deduplicatedSelectedContextSegments) {
      const identity =
        `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`;

      if (!suppliedSegmentByIdentity.has(identity)) {
        throw new Error(
          "Ollama returned a selected context segment that was not supplied in this invocation.",
        );
      }
    }

    const selectedSegmentIdentities = new Set(
      deduplicatedSelectedContextSegments.map(
        (segment) =>
          `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
      ),
    );

    const suppliedConversationSourceIds =
      new Set(
        (context.history || [])
          .map((turn) => turn.sourceTurnId)
          .filter(
            (sourceTurnId): sourceTurnId is string =>
              typeof sourceTurnId === "string" &&
              Boolean(sourceTurnId),
          ),
      );

    const suppliedProjectContextSources =
      new Set(
        (context.projectContextExcerpts || []).map(
          (excerpt) =>
            `${excerpt.relativePath}:${excerpt.lineNumber}`,
        ),
      );

    if (context.observeParsedSupportSourceReferences) {
      context.observeParsedSupportSourceReferences(
        result.supportSourceReferences,
      );
    }

    const deduplicatedSupportSourceReferences =
      result.supportSourceReferences.filter(
        (reference, index, references) => {
          const referenceKey =
            reference.type === "conversation_turn"
              ? `conversation_turn:${reference.sourceTurnId}`
              : `project_context_excerpt:${reference.relativePath}:${reference.lineNumber}`;

          return (
            references.findIndex((candidate) => {
              const candidateKey =
                candidate.type === "conversation_turn"
                  ? `conversation_turn:${candidate.sourceTurnId}`
                  : `project_context_excerpt:${candidate.relativePath}:${candidate.lineNumber}`;

              return candidateKey === referenceKey;
            }) === index
          );
        },
      );

    const suppliedProjectContextExcerptBySource =
      new Map(
        (context.projectContextExcerpts || []).map(
          (excerpt) => [
            `${excerpt.relativePath}:${excerpt.lineNumber}`,
            excerpt.excerpt,
          ],
        ),
      );

    for (const reference of deduplicatedSupportSourceReferences) {
      if (reference.type === "conversation_turn") {
        if (
          !reference.sourceTurnId ||
          !suppliedConversationSourceIds.has(
            reference.sourceTurnId,
          )
        ) {
          throw new Error(
            "Ollama returned a conversation support reference that was not supplied in this invocation.",
          );
        }

        continue;
      }

      const sourceKey =
        `${reference.relativePath}:${reference.lineNumber}`;

      if (
        !reference.relativePath ||
        !reference.lineNumber ||
        !suppliedProjectContextSources.has(sourceKey)
      ) {
        throw new Error(
          "Ollama returned a project-context support reference that was not supplied in this invocation.",
        );
      }
    }

    for (const reference of deduplicatedSupportSourceReferences) {
      if (reference.type !== "project_context_excerpt") {
        continue;
      }

      const childrenForParent = suppliedSegmentCandidates.filter(
        (segment) =>
          segment.parentRelativePath === reference.relativePath &&
          segment.parentLineNumber === reference.lineNumber,
      );

      if (childrenForParent.length === 0) {
        continue;
      }

      const hasSelectedChild = childrenForParent.some(
        (segment) =>
          selectedSegmentIdentities.has(
            `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
          ),
      );

      if (!hasSelectedChild) {
        throw new Error(
          "Ollama returned project-context support without selecting a supplied child segment for that parent.",
        );
      }
    }

    if (context.observeValidatedSelectedContextSegments) {
      context.observeValidatedSelectedContextSegments(
        deduplicatedSelectedContextSegments,
      );
    }

    const supportDrivenEvidenceSources =
      deduplicatedSupportSourceReferences          .filter(
            (
              reference,
            ): reference is MatildaSupportSourceReference & {
              type: "project_context_excerpt";
              relativePath: string;
              lineNumber: number;
            } =>
              reference.type ===
                "project_context_excerpt" &&
              typeof reference.relativePath === "string" &&
              typeof reference.lineNumber === "number",
          )
        .map((reference) => {
          const sourceKey =
            `${reference.relativePath}:${reference.lineNumber}`;

          const suppliedExcerpt =
            suppliedProjectContextExcerptBySource.get(
              sourceKey,
            );

          if (suppliedExcerpt === undefined) {
            throw new Error(
              "Validated project-context support reference has no supplied excerpt.",
            );
          }

          return {
            reference,
            excerpt: suppliedExcerpt,
          };
        });

    const explicitRequestEvidenceSources =
      context.explicitEvidenceRequest
        ? (context.projectContextExcerpts || []).map(
            (excerpt) => ({
              reference: {
                type:
                  "project_context_excerpt" as const,
                relativePath:
                  excerpt.relativePath,
                lineNumber:
                  excerpt.lineNumber,
              },
              excerpt:
                excerpt.excerpt,
            }),
          )
        : [];

    const deterministicEvidenceSources =
      context.explicitEvidenceRequest
        ? explicitRequestEvidenceSources
        : supportDrivenEvidenceSources;

    const validatedEvidence =
      deterministicEvidenceSources.length > 0
        ? {
            sources:
              deterministicEvidenceSources,
          }
        : null;

    return {
      reply: result.reply,
      explanationStatus: result.explanationStatus,
      supportSourceReferences:
        deduplicatedSupportSourceReferences,
      evidence: validatedEvidence,
      evidenceSufficient:
        deduplicatedSupportSourceReferences.length > 0,
      investigationLifecycle:
        result.investigationLifecycle,
      packageSemantics:
        result.packageSemantics,
      durableInterpretation:
        result.durableInterpretation,
    };
  } catch (error) {
    if (
      error instanceof Error &&
      error.name === "AbortError"
    ) {
      throw new Error("Ollama chat request timed out.");
    }

    throw error;
  } finally {
    clearTimeout(timeout);
  }
}
