import fetch from "node-fetch";

/**
 * 💬 Simple conversational bridge for Matilda.
 * Sends plain text to Ollama and returns the model's response.
 */
export async function ollamaChat(message: string): Promise<string> {
  try {
    const res = await fetch("http://localhost:11434/api/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "llama3.1:8b", // or your preferred local model
        prompt: message,
        stream: false,
      }),
    });

    if (!res.ok) {
      console.error("⚠️ ollamaChat HTTP error:", res.status);
      return "🤖 (chat unavailable)";
    }

    const data = await res.json();
    return data?.response?.trim() || "🤖 (no response)";
  } catch (err) {
    console.error("❌ ollamaChat failure:", err);
    return "🤖 (error during chat)";
  }
}
