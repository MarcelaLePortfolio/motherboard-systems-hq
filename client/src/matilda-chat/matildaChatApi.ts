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

export async function sendMatildaMessage(
  message: string
): Promise<MatildaChatResponse> {
  const response = await fetch("/api/chat", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      agent: "matilda",
      message,
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
