const OLLAMA_API_URL = "http://localhost:11434/api/generate";
const MODEL = "llama3:8b";

async function sendMessage() {
  const input = document.getElementById("input");
  const userText = input.value.trim();
  if (!userText) return;

  const messages = document.getElementById("messages");

  // Append user message
  const userMsg = document.createElement("div");
  userMsg.className = "message user-message";
  userMsg.textContent = userText;
  messages.appendChild(userMsg);

  // Prepare bot message container
  const botMsg = document.createElement("div");
  botMsg.className = "message bot-message";
  messages.appendChild(botMsg);

  input.value = "";
  messages.scrollTop = messages.scrollHeight;

  // Send message to Ollama via streaming
  const res = await fetch(OLLAMA_API_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: MODEL,
      prompt: userText,
      stream: true
    })
  });

  const reader = res.body.getReader();
  const decoder = new TextDecoder();

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    const chunk = decoder.decode(value, { stream: true }).trim();
    const lines = chunk.split("\n").filter(Boolean);

    for (const line of lines) {
      try {
        const data = JSON.parse(line);
        if (data.response) {
          botMsg.textContent += data.response;
          messages.scrollTop = messages.scrollHeight;
        }
      } catch (err) {
        console.error("❌ Streaming parse error:", err, line);
      }
    }
  }
}
