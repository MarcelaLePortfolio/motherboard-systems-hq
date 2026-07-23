export interface MatildaChatResponse {
  ok: boolean;
  agent: string;
  message: string;
  reasoning: string;
  reply: string;
  meta: {
    timestamp: string;
    pipeline: "matilda-stub";
    interpretation_entry_id: string;
  };
  draft_package_updated: boolean;
  canonical_package_created: boolean;
  delegation_authorized: boolean;
  validation_authorized: boolean;
  envelope_authorized: boolean;
  execution_authorized: boolean;
}

export interface MatildaConversationTurn {
  turn_id: string;
  project_id: string;
  conversation_id: string;
  user_message: string;
  assistant_reply: string;
  interpretation_entry_id: string;
  created_at: string;
}

export interface MatildaChatHistoryResponse {
  ok: boolean;
  project_id: string;
  conversation_id: string;
  turns: MatildaConversationTurn[];
}

export interface SendMatildaMessageInput {
  message: string;
  projectId: string;
  conversationId: string;
}

export async function sendMatildaMessage(
  input: SendMatildaMessageInput
): Promise<MatildaChatResponse> {

  const response = await fetch("/api/chat", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      agent: "matilda",
      project_id: input.projectId,
      conversation_id: input.conversationId,
      message: input.message,
    }),
  });

  if (!response.ok) {
    let errorMessage = "Matilda chat request failed";

    try {
      const body = (await response.json()) as { error?: string };

      if (body.error) {
        errorMessage = body.error;
      }
    } catch {
      // Preserve the fallback when the response is not JSON.
    }

    throw new Error(
      `${errorMessage} (${response.status} ${response.statusText})`
    );
  }

  return response.json() as Promise<MatildaChatResponse>;
}


export async function getMatildaChatHistory(
  projectId: string
): Promise<MatildaChatHistoryResponse> {
  const response = await fetch(
    `/api/chat/history?project_id=${encodeURIComponent(projectId)}`
  );

  if (!response.ok) {
    let errorMessage = "Matilda chat history request failed";

    try {
      const body = (await response.json()) as { error?: string };

      if (body.error) {
        errorMessage = body.error;
      }
    } catch {
      // Preserve the fallback when the response is not JSON.
    }

    throw new Error(
      `${errorMessage} (${response.status} ${response.statusText})`
    );
  }

  return response.json() as Promise<MatildaChatHistoryResponse>;
}
