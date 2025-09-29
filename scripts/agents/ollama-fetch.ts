console.log("🧪 <0001FAC5> ollama-fetch.ts in TEST SELF-HEAL MODE");

export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  const userText = convo.find(m => m.role === "user")?.content || "";

  if (/getReader/i.test(userText)) {
    throw new Error("resp.body?.getReader is not a function");
  }
  if (/json/i.test(userText)) {
    throw new Error("Unexpected token in JSON at position 1");
  }

  return "✅ <0001FAC5> Normal ollamaChat response";
}
