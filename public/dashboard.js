const MATILDA_API = "http://localhost:3001/matilda";

async function sendMessageToMatilda(message) {
  try {
    const response = await fetch(MATILDA_API, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message }),
    });
    const data = await response.json();
    return data.message;
  } catch (err) {
    console.error("❌ Frontend Matilda error:", err);
    return "❌ Unable to reach Matilda";
  }
}

// Example hookup to input and button
document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("chatInput");
  const button = document.getElementById("sendButton");
  const output = document.getElementById("chatOutput");

  button.addEventListener("click", async () => {
    const msg = input.value;
    output.textContent += `You: ${msg}\n`;
    input.value = "";
    const reply = await sendMessageToMatilda(msg);
    output.textContent += `Matilda: ${reply}\n`;
  });
});
