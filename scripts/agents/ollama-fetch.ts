export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  const convoText = convo.map(m => `${m.role}: ${m.content}`).join("\n");
  const resp = await fetch("http://127.0.0.1:11434/api/generate", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model: "llama3:8b", prompt: convoText })
  });
  const raw = await resp.text();
  let combined = "";
  for (const line of raw.split("\n")) {
    if (!line.trim()) continue;
    try {
      const obj = JSON.parse(line);
      if (obj.response) combined += obj.response;
    } catch { /* ignore parse errors */ }
  }
  return combined.trim() || raw.trim() || "(no response)";
}
