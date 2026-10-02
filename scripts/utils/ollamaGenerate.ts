export type OllamaGenerateOptions = {
  base_url?: string;
  model?: string;
  timeout_ms?: number;
  prompt: string;
  format?: unknown;
  options?: Record<string, unknown>;
  fetch_impl?: typeof fetch;
};

export type OllamaGenerateResult = {
  response: string;
};

const DEFAULT_OLLAMA_BASE_URL =
  process.env.OLLAMA_BASE_URL?.trim() || "http://127.0.0.1:11434";

const DEFAULT_OLLAMA_MODEL =
  process.env.OLLAMA_CHAT_MODEL?.trim() || "llama3.1:8b";

const DEFAULT_OLLAMA_TIMEOUT_MS = Number(
  process.env.OLLAMA_CHAT_TIMEOUT_MS || 120000,
);

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Ollama generation ${field} is required.`);
  }

  return value.trim();
}

function requireTimeout(value: unknown): number {
  if (
    typeof value !== "number"
    || !Number.isFinite(value)
    || value <= 0
  ) {
    throw new Error("Ollama generation timeout_ms must be a positive number.");
  }

  return value;
}

export async function ollamaGenerate(
  input: OllamaGenerateOptions,
): Promise<OllamaGenerateResult> {
  const baseUrl = requireText(
    input.base_url ?? DEFAULT_OLLAMA_BASE_URL,
    "base_url",
  ).replace(/\/+$/, "");

  const model = requireText(
    input.model ?? DEFAULT_OLLAMA_MODEL,
    "model",
  );

  const prompt = requireText(input.prompt, "prompt");

  const timeoutMs = requireTimeout(
    input.timeout_ms ?? DEFAULT_OLLAMA_TIMEOUT_MS,
  );

  const fetchImpl = input.fetch_impl ?? fetch;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const body: Record<string, unknown> = {
      model,
      prompt,
      stream: false,
    };

    if (input.format !== undefined) {
      body.format = input.format;
    }

    if (input.options !== undefined) {
      body.options = input.options;
    }

    const response = await fetchImpl(`${baseUrl}/api/generate`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });

    if (!response.ok) {
      const detail = await response.text();

      throw new Error(
        `Ollama generation failed with HTTP ${response.status}: ${detail}`,
      );
    }

    const payload = await response.json() as {
      response?: unknown;
    };

    if (
      typeof payload.response !== "string"
      || payload.response.trim().length === 0
    ) {
      throw new Error(
        "Ollama generation returned an empty or invalid response.",
      );
    }

    return {
      response: payload.response,
    };
  } finally {
    clearTimeout(timeout);
  }
}
