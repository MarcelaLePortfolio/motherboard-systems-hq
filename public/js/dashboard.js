const chatForm = document.querySelector("#chat-form");
const chatInput = document.querySelector("#chat-input");
const chatLog = document.querySelector("#chat-log");

chatForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  const message = chatInput.value.trim();
  if (!message) return;

  chatLog.innerHTML += `<div class="user-message">${message}</div>`;
  chatInput.value = "";

  try {
    const res = await fetch("http://localhost:3001/matilda", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message }),
    });
    const data = await res.json();
    chatLog.innerHTML += `<div class="matilda-message">${data.message || "No response"}</div>`;
  } catch (err) {
    chatLog.innerHTML += `<div class="matilda-error">Error connecting to Matilda</div>`;
    console.error(err);
  }
});
