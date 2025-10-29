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
      body: JSON.stringify({ model: "llama3.1:8b", prompt: message, stream: true }),
    });


    if (!res.ok || !res.body) {
      console.error("⚠️ ollamaChat HTTP error:", res.status);
      return "🤖 (chat unavailable)";
    }

    const reader = res.body.getReader();
    const decoder = new TextDecoder();
    let lastLine = "";
    const start = Date.now();

    while (true) {
      const { value, done } = await reader.read();
      if (done) break;
      const chunk = decoder.decode(value, { stream: true });
      const lines = chunk.split("\n").filter(Boolean);
      if (lines.length) lastLine = lines.pop();
      if (Date.now() - start > 10000) break;
    }

    const parsed = JSON.parse(lastLine || {});
    console.log("<0001fa9f> 💬 ollamaChat streamed (timed):", parsed);
    return parsed?.response?.trim() || "🤖 (no response)";
  } catch (err) {
    console.error("❌ ollamaChat streaming failure:", err);
    return "🤖 (error during chat)";
  }
}
