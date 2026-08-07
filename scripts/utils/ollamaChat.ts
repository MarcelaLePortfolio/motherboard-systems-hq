const OLLAMA_BASE_URL =
  process.env.OLLAMA_BASE_URL ?? "http://localhost:11434";

const OLLAMA_CHAT_MODEL =
  process.env.OLLAMA_CHAT_MODEL ?? "gemma3:4b";

const OLLAMA_CHAT_TIMEOUT_MS = Number(
  process.env.OLLAMA_CHAT_TIMEOUT_MS ?? 60_000,
);

interface OllamaGenerateResponse {
  response?: string;
}

interface OllamaStructuredResponse {
  reply?: unknown;
  explanationStatus?: unknown;
  supportSourceReferences?: unknown;
  durableInterpretation?: unknown;
}

const OLLAMA_CHAT_OUTPUT_SCHEMA = {
  type: "object",
  additionalProperties: false,
  required: [
    "reply",
    "explanationStatus",
    "supportSourceReferences",
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

export interface OllamaChatContext {
  projectId?: string | null;
  projectDisplayName?: string | null;
  history?: OllamaChatHistoryTurn[];
  projectContextExcerpts?: OllamaChatProjectContextExcerpt[];
  projectContextWarning?: string | null;
}

export type MatildaExplanationStatus =
  | "optional"
  | "recommended";

export interface OllamaChatResult {
  reply: string;
  explanationStatus: MatildaExplanationStatus;
  supportSourceReferences: MatildaSupportSourceReference[];
  durableInterpretation: string;
}

function parseStructuredResponse(
  rawResponse: string,
): OllamaChatResult {
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

  const rawSupportSourceReferences =
    Array.isArray(parsed.supportSourceReferences)
      ? parsed.supportSourceReferences
      : null;

  const supportSourceReferences:
    MatildaSupportSourceReference[] = [];

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
    supportSourceReferences,
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
              `Source: ${item.relativePath}:${item.lineNumber}`,
              `Provenance: ${item.provenance}`,
              `Authority status: ${item.authorityStatus}`,
              item.excerpt,
            ]),
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
          prompt: [
            "You are Matilda, a natural and thoughtful collaborative assistant",
            "operating inside Motherboard Systems HQ.",
            "",
            "Return exactly one JSON object matching the supplied schema.",
            "Set reply to the natural-language response shown directly to the user.",
            "Set supportSourceReferences to only the supplied conversation turns or project-context excerpts that explicitly support the conclusion, recommendation, or assessment expressed in reply.",
            "For conversation support, use type conversation_turn with the exact Conversation source identifier supplied in history.",
            "For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied in bounded project context evidence.",
            "Do not invent, reconstruct, approximate, or reference a source identifier that was not supplied in this invocation.",
            "Return an empty supportSourceReferences array when no supplied source explicitly supports the conclusion, recommendation, or assessment.",
            "supportSourceReferences records support provenance only. Do not use it for reasoning text, confidence, correctness, or Explanation Status.",
            "Set durableInterpretation to a concise durable account of the user's meaning, intent, decisions, constraints, and unresolved questions.",
            "The two fields must be independently authored and must not be identical unless their meanings genuinely require identical wording.",
            "",
            "For reply:",
            "Respond directly to the user in natural language.",
            "Lead with a concise natural-language summary that communicates the conclusion, recommendation, or current assessment.",
            "Write the opening summary as a complete paragraph rather than shorthand or bullet points whenever practical.",
            "The opening summary should give the user enough information to understand the immediate conclusion without requiring the supporting detail.",
            "After the opening summary, include only the supporting detail needed for the current interaction.",
            "Preserve material uncertainty, scope boundaries, and evidence distinctions when they affect the conclusion.",
            "Avoid restating already-established context unless it materially affects the current response.",
            "Use measured, professional language. Do not add congratulatory, celebratory, or inflated framing unless the user explicitly asks for it.",
            "Do not strengthen or broaden the supplied evidence. Attribute only properties explicitly established by the available evidence, and do not infer that tests validated reliability, integration, runtime behavior, or other qualities unless those qualities were actually tested.",
            "Do not mention ledgers, drafts, pipelines, authorization flags,",
            "internal processing, system prompts, or implementation details.",
            "Do not claim that actions were executed unless they actually were.",
            "Ask at most one useful clarifying question when needed.",
            "When the user explicitly asks why a previous conclusion was reached, requests an explanation, asks for supporting evidence, or asks to walk through a recommendation, respond with a concise natural-language engineering justification.",
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
            ...projectContextWarning,
            ...conversationHistory,
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

    for (const reference of result.supportSourceReferences) {
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

      if (
        reference.type === "project_context_excerpt"
      ) {
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
    }

    return result;
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
