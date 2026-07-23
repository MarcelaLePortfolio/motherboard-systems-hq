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

export interface MatildaConversationSummary {
  conversation_id: string;
  project_id: string;
  status: string;
  created_at: string;
  updated_at: string;
  last_active_at: string;
  title: string;
  turn_count: number;
  is_active: number;
}

export interface MatildaConversationListResponse {
  ok: boolean;
  project_id: string;
  conversations: MatildaConversationSummary[];
}

export interface MatildaConversationControlResponse {
  ok: boolean;
  project_id: string;
  conversation: {
    conversation_id: string;
    project_id: string;
    status: string;
    created_at: string;
    updated_at: string;
    last_active_at: string;
  };
  conversations: MatildaConversationSummary[];
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


async function readConversationControlResponse<T>(
  response: Response,
  fallbackMessage: string
): Promise<T> {
  if (!response.ok) {
    let errorMessage = fallbackMessage;

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

  return response.json() as Promise<T>;
}

export async function getMatildaConversations(
  projectId: string
): Promise<MatildaConversationListResponse> {
  const response = await fetch(
    `/api/chat/conversations?project_id=${encodeURIComponent(projectId)}`
  );

  return readConversationControlResponse(
    response,
    "Failed to load Matilda conversations"
  );
}

export async function createMatildaConversation(
  projectId: string
): Promise<MatildaConversationControlResponse> {
  const response = await fetch("/api/chat/conversations", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      project_id: projectId,
    }),
  });

  return readConversationControlResponse(
    response,
    "Failed to create Matilda conversation"
  );
}

export async function setActiveMatildaConversation(
  projectId: string,
  conversationId: string
): Promise<MatildaConversationControlResponse> {
  const response = await fetch("/api/chat/conversations/active", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      project_id: projectId,
      conversation_id: conversationId,
    }),
  });

  return readConversationControlResponse(
    response,
    "Failed to switch Matilda conversation"
  );
}
