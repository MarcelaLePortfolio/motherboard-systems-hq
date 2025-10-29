import fetch from "node-fetch";

/**
console.log("<0001fa9f> 💬 ollamaChat invoked with:", message);

 * 💬 Simple conversational bridge for Matilda.
 * Sends plain text to Ollama and returns the model's response.
 */
export async function ollamaChat(message: string): Promise<string> {
  try {
    const res = await fetch("http://localhost:11434/api/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "llama3.1:8b",
        prompt: message,
        stream: false
      }),
    });

    if (!res.ok) {
      console.error("⚠️ ollamaChat HTTP error:", res.status);
      return "🤖 (chat unavailable)";
    }

    const text = await res.text();
    try {
      const parsed = JSON.parse(text);
      console.log("<0001fa9f> 💬 ollamaChat response:", parsed);
      return parsed?.response?.trim() || "🤖 (no response)";
    } catch {
      const lastLine = text.trim().split("\n").pop();
      const parsed = JSON.parse(lastLine || "{}");
      console.log("<0001fa9f> 💬 ollamaChat NDJSON parsed:", parsed);
      return parsed?.response?.trim() || "�� (no response)";
    }
  } catch (err) {
    console.error("❌ ollamaChat failure:", err);
    return "🤖 (error during chat)";
  }
}
