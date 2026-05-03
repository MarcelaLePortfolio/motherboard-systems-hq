/**
 * Matilda chat pipeline helper.
 *
 * Deterministic local response layer for /api/chat.
 * Returns a structured response object without placeholder copy,
 * external runtime calls, randomness, or async side effects.
 */

export type MatildaChatInput = {
  message: string;
  agent?: string | null;
};

export type MatildaChatMeta = {
  timestamp: string;
  pipeline: "matilda-stub";
};

export type MatildaChatResult = {
  ok: boolean;
  agent: string;
  message: string;
  reasoning: string;
  reply: string;
  meta: MatildaChatMeta;
};

function normalizeWhitespace(value: string): string {
  return value.replace(/\s+/g, " ").trim();
}

export async function runMatildaStub(
  input: MatildaChatInput
): Promise<MatildaChatResult> {
  const rawMessage = typeof input.message === "string" ? input.message : "";
  const message = normalizeWhitespace(rawMessage);

  if (!message) {
    throw new Error("MatildaChatStub: 'message' must be a non-empty string.");
  }

  const rawAgent = input.agent || "matilda";
  const agent = String(rawAgent).toLowerCase();

  const reasoningParts: string[] = [
    `Agent selected: ${agent}`,
    `Message length: ${message.length}`,
    "Mode: deterministic local response layer",
    "External runtime: disabled",
    "Execution class: UI-safe acknowledgement",
  ];

  const reasoning = reasoningParts.join(" | ");

  const replyLines: string[] = [
    "Matilda received your request.",
    `Input: \"${message}\"`,
    "Status: deterministic local response active.",
    "Runtime handoff: not enabled in this corridor.",
    "Next step: provide a specific task or request an auditable system action.",
  ];

  const reply = replyLines.join("\n");

  const meta: MatildaChatMeta = {
    timestamp: "deterministic-local",
    pipeline: "matilda-stub",
  };

  return {
    ok: true,
    agent,
    message,
    reasoning,
    reply,
    meta,
  };
}
