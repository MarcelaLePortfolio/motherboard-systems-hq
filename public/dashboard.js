// <0001fbDB> Dashboard Chat – Compatible with full layout (restored Matilda chat)
document.addEventListener("DOMContentLoaded", () => {
  const input = document.querySelector("input[type='text'], #userInput");
  const log = document.getElementById("chatLog") || document.querySelector(".chat-log");
  const sendBtn = document.getElementById("sendBtn") || document.querySelector("button");

  if (!input || !log) return console.warn("⚠️ Chat elements not found.");

  async function sendMessage() {
    const msg = input.value.trim();
    if (!msg) return;
    log.innerHTML += `<div><b>You:</b> ${msg}</div>`;
    input.value = "";

    try {
      const res = await fetch("/matilda", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: msg }),
      });
      const data = await res.json();
      const reply = data.reply || data.result || "✅ Task completed!";
      log.innerHTML += `<div><b>Matilda:</b> ${reply}</div>`;
      log.scrollTop = log.scrollHeight;
    } catch (err) {
      log.innerHTML += `<div style="color:red;">Error contacting Matilda</div>`;
    }
  }

  // Enter key or click → send
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") sendMessage();
  });
  sendBtn?.addEventListener("click", sendMessage);
});

/* ----------------- OPS STREAM TICKER ----------------- */
async function refreshOpsStream() {
  try {
    const res = await fetch("/ops");
    const { events } = await res.json();
    const container = document.getElementById("opsStream");
    if (!container) return;
    container.innerHTML = events.map(e => {
      const ts = new Date(e.ts).toLocaleTimeString();
      return `<div>[${ts}] ${e.event}</div>`;
    }).join("");
  } catch (err) {
    console.error("OPS Stream refresh failed", err);
  }
}
setInterval(refreshOpsStream, 3000);
