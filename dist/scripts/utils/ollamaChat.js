/**
 * ollamaChat.ts — diagnostic version to reveal full Ollama payload
 */
export async function ollamaChat(message) {
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
        console.log("<0001fa9f> 🧩 Full Ollama raw payload:", JSON.stringify(data, null, 2));
        // Intentionally force output to show structure
        if (!data || Object.keys(data).length === 0) {
            return "🤖 (empty payload)";
        }
        // Attempt to grab possible fields
        const reply = data?.response ||
            data?.message ||
            data?.output?.[0]?.content ||
            data?.content ||
            data?.text ||
            "(unknown format — see logs)";
        return String(reply).trim();
    }
    catch (err) {
        console.error("❌ ollamaChat failure:", err);
        return "🤖 (error during chat)";
    }
}
