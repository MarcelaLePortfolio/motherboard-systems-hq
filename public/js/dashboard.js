/**
 * 🔍 Dashboard chat + delegate wiring debug
 */

document.addEventListener("DOMContentLoaded", () => {
  console.log("🔥 Dashboard JS loaded");

  const chatInput   = document.querySelector("#userInput");
  const sendBtn     = document.querySelector("#sendBtn");
  const delegateBtn = document.querySelector("#delegateButton");
  const chatLog     = document.querySelector("#chatLog");

  console.log("🔗 DOM bindings:", { chatInput, sendBtn, delegateBtn, chatLog });

  if (!chatInput || !sendBtn || !chatLog) {
    console.warn("⚠️ Missing one or more core chat elements (#userInput, #sendBtn, #chatLog)");
  }

  if (!delegateBtn) {
    console.warn("⚠️ No #delegateButton found in DOM — delegate wiring will NOT work.");
    return;
  }

  const MATILDA_API = "http://localhost:3001/matilda";

  /* --- Normal chat send --- */
  sendBtn?.addEventListener("click", async () => {
    const message = chatInput.value.trim();
    if (!message) return;

    chatLog.innerHTML += `<div class="chat-message user">${message}</div>`;
    chatInput.value = "";

    try {
      const res = await fetch(MATILDA_API, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message })
      });

      const data = await res.json();
      chatLog.innerHTML += `<div class="chat-message matilda">${data.message}</div>`;
    } catch (err) {
      console.error("❌ Chat send failed:", err);
      chatLog.innerHTML += `<div class="chat-message error">Matilda had trouble reaching the server.</div>`;
    }
  });

  /* --- 🚀 Delegation send --- */
  delegateBtn.addEventListener("click", async () => {
    const instruction = chatInput.value.trim();
    if (!instruction) {
      console.log("ℹ️ Delegate clicked with empty input — ignoring.");
      return;
    }

    console.log("🚀 Delegate click captured with instruction:", instruction);

    chatLog.innerHTML += `<div class="chat-message user">🚀 Delegate: ${instruction}</div>`;
    chatInput.value = "";

    try {
      const res = await fetch(MATILDA_API, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: instruction, delegate: instruction })
      });

      const data = await res.json();
      console.log("📬 Matilda response payload:", data);
      chatLog.innerHTML += `<div class="chat-message matilda">${data.message}</div>`;
    } catch (err) {
      console.error("❌ Delegate request failed:", err);
      chatLog.innerHTML += `<div class="chat-message error">Matilda couldn't delegate that task (network error).</div>`;
    }
  });
});
