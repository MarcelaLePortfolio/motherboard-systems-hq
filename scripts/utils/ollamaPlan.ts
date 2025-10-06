import ollama from "ollama";

export async function ollamaPlan(command: string, payload: any = {}) {
  try {
    const response = await ollama.chat({
      model: "cade-brain",
      messages: [
        { role: "system", content: "You are Cade. Respond only in valid JSON." },
        { role: "user", content: `Command: ${command}` }
      ]
    });
    return JSON.parse(response.message?.content || "{}");
  } catch (err) {
    console.error("❌ ollamaPlan failed:", err);
    return null;
  }
}