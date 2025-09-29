export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  console.log("💥 Simulating a getReader failure inside ollamaChat");
  throw new Error("resp.body?.getReader is not a function");
}
