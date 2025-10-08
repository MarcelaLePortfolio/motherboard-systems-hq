import ollama from "ollama";

/**
 * ollamaPlan
 * -----------
 * Cleans and returns runnable TypeScript code — removes markdown and stray imports.
 */
export async function ollamaPlan(prompt: string): Promise<string> {
  try {
    const response = await ollama.chat({
      model: "mistral",
      messages: [
        {
          role: "system",
          content:
            "You are a code generator. Respond ONLY with valid TypeScript code inside an async function. Do NOT include imports, markdown fences, or explanations.",
        },
        { role: "user", content: prompt },
      ],
    });

    let raw = response?.message?.content?.trim() ?? "";
    if (!raw) throw new Error("Empty Ollama response");

    // 🧹 Sanitize: remove code fences, language tags, and imports
    raw = raw
      .replace(/```[a-zA-Z]*\n?/g, "")
      .replace(/```/g, "")
      .replace(/^import .*?;$/gm, "")
      .replace(/from\s+['"].*?['"];?/gm, "")
      .trim();

    // Wrap if not already exported
    if (!raw.startsWith("export default")) {
      raw = `export default async function run(params: any = {}, ctx: any = {}) {\n${raw}\n  return "✅ Dynamic skill executed.";\n}`;
    }

    return raw;
  } catch (err: any) {
    console.error("❌ ollamaPlan error:", err.message);
    return `export default async function run(){throw new Error("${err.message}")}`;
  }
}
