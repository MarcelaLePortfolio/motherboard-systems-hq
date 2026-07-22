const OLLAMA_BASE_URL =
  process.env.OLLAMA_BASE_URL ?? "http://localhost:11434";

const OLLAMA_CHAT_MODEL =
  process.env.OLLAMA_CHAT_MODEL ?? "gemma3:4b";

const OLLAMA_CHAT_TIMEOUT_MS = Number(
  process.env.OLLAMA_CHAT_TIMEOUT_MS ?? 60_000
);

interface OllamaGenerateResponse {
  response?: string;
}

export async function ollamaChat(message: string): Promise<string> {
  const trimmedMessage = message.trim();

  if (!trimmedMessage) {
    throw new Error("Ollama chat requires a non-empty message.");
  }

  const controller = new AbortController();
  const timeout = setTimeout(
    () => controller.abort(),
    OLLAMA_CHAT_TIMEOUT_MS
  );

  try {
    const response = await fetch(`${OLLAMA_BASE_URL}/api/generate`, {
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
          "",
          `User: ${trimmedMessage}`,
        ].join("\n"),
      }),
    });

    if (!response.ok) {
      throw new Error(
        `Ollama returned ${response.status} ${response.statusText}.`
      );
    }

    const data = (await response.json()) as OllamaGenerateResponse;
    const reply = data.response?.trim();

    if (!reply) {
      throw new Error("Ollama returned an empty response.");
    }

    return reply;
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      throw new Error("Ollama chat request timed out.");
    }

    throw error;
  } finally {
    clearTimeout(timeout);
  }
}
