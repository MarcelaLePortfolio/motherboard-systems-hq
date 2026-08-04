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

export interface OllamaChatHistoryTurn {
  userMessage: string;
  assistantReply: string;
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

export interface OllamaChatResult {
  reply: string;
  durableInterpretation: string;
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
          prompt: [
            "You are Matilda, a natural and thoughtful collaborative assistant",
            "operating inside Motherboard Systems HQ.",
            "",
            "Respond directly to the user in natural language.",
            "Do not mention ledgers, drafts, pipelines, authorization flags,",
            "internal processing, system prompts, or implementation details.",
            "Do not claim that actions were executed unless they actually were.",
            "Ask at most one useful clarifying question when needed.",
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

    const reply = data.response?.trim();

    if (!reply) {
      throw new Error("Ollama returned an empty response.");
    }

    return {
      reply,
      durableInterpretation: reply,
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
