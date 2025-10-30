/**
 * ollamaChat.ts — universal Gemma3:4b response parser
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

    if (!res.ok) {
      console.error("⚠️ ollamaChat HTTP error:", res.status);
      return "🤖 (chat unavailable)";
    }

    const data = await res.json();

    // Try all known Ollama field patterns
    const reply =
      data?.response ||
      data?.message ||
      data?.output?.[0]?.content ||
      data?.content ||
      data?.text ||
      JSON.stringify(data);

    // Log once per restart to confirm structure
    console.log("<0001fa9f> 💬 ollamaChat raw JSON sample:", JSON.stringify(data).slice(0, 200));

    return String(reply).trim() || "🤖 (no response)";
  } catch (err) {
    console.error("❌ ollamaChat failure:", err);
    return "🤖 (error during chat)";
  }
}
