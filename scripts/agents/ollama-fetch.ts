export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  console.log("🧪 TEST MODE: ollama-fetch is throwing simulated getReader error");
  throw new Error("resp.body?.getReader is not a function (TEST MODE)");
}
