import "./sse-ops.js";
import "./sse-reflections-shim.js";

const chatForm = document.getElementById("matilda-chat-form");
const chatInput = document.getElementById("matilda-chat-input");
const chatOutput = document.getElementById("project-viewport-output");

const delegationForm =
document.getElementById("task-delegation-form") ||
document.getElementById("delegation-form");
const delegationInput =
document.getElementById("task-delegation-input") ||
document.getElementById("delegation-input") ||
chatInput;
const delegationLog =
document.getElementById("task-delegation-log") ||
document.getElementById("delegation-log");

async function sendChat(message) {
const res = await fetch("/api/chat", {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({ message, agent: "matilda" }),
});
const data = await res.json();
return data.response || JSON.stringify(data);
}

if (chatForm && chatInput && chatOutput) {
chatForm.addEventListener("submit", async (e) => {
e.preventDefault();
const text = chatInput.value.trim();
if (!text) return;

```
chatOutput.innerHTML = "<p><em>Matilda is thinking…</em></p>";

try {
  const reply = await sendChat(text);
  chatOutput.innerHTML = `<div class="matilda-reply">${reply}</div>`;
} catch (err) {
  chatOutput.innerHTML = `<p style="color:red;">Chat error: ${err}</p>`;
}

chatInput.value = "";
```

});
}

async function sendDelegation(description) {
const res = await fetch("/api/delegate-task", {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({ description }),
});
const data = await res.json();
return data;
}

function appendDelegationLog(entryText) {
if (!delegationLog) return;
const item = document.createElement("div");
item.className = "delegation-entry";
item.textContent = entryText;
delegationLog.prepend(item);
}

if (delegationForm && delegationInput) {
delegationForm.addEventListener("submit", async (e) => {
e.preventDefault();
const text = delegationInput.value.trim();
if (!text) return;

```
appendDelegationLog(`Delegating: ${text}`);

try {
  const result = await sendDelegation(text);
  appendDelegationLog(
    `Delegated ✓ (id: ${result.id ?? "n/a"}, status: ${result.status ?? "queued"})`
  );
  if (chatOutput) {
    chatOutput.innerHTML = `<pre>${JSON.stringify(result, null, 2)}</pre>`;
  }
} catch (err) {
  appendDelegationLog(`Delegation error: ${err}`);
}

delegationInput.value = "";
```

});
}
