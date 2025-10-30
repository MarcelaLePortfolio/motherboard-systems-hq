/**
 * ollamaChat.ts — clean Gemma3:4b local chat helper
 */
export async function ollamaChat(message: string): Promise<string> {
  try {
    const res = await fetch("http://localhost:11434/api/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "gemma3:4b",
        prompt: message,
        stream: false,
      }),
    });
    if (!res.ok) return "🤖 (Ollama unavailable)";
    const data = await res.json();
    return data?.response?.trim() || "🤖 (no response)";
  } catch (err) {
    console.error("❌ ollamaChat error:", err);
    return "�� (error)";
  }
}
