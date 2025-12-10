import "./sse-ops.js";
import "./sse-reflections-shim.js";

// Utility helpers
function $(id) {
return document.getElementById(id);
}

// Matilda chat elements
const chatForm = $("matilda-chat-form");
const chatInput = $("matilda-chat-input");
const chatOutput = $("project-viewport-output");

// Delegation elements (with fallbacks)
const delegationForm =
$("task-delegation-form") || $("delegation-form");
const delegationInput =
$("task-delegation-input") || $("delegation-input") || chatInput;
const delegationLog =
$("task-delegation-log") || $("delegation-log");

// -------------------------
// Matilda Chat Logic
// -------------------------

async function sendChat(message) {
const res = await fetch("/api/chat", {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({ message, agent: "matilda" }),
});

if (!res.ok) {
throw new Error(`HTTP ${res.status}`);
}

const data = await res.json();
// Expecting { response: string, ... } but fall back to raw JSON if not
return data.response || JSON.stringify(data, null, 2);
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
  chatOutput.innerHTML = `<div class='matilda-reply'>${reply}</div>`;
} catch (err) {
  chatOutput.innerHTML = `<p style="color:red;">Chat error: ${String(
    err
  )}</p>`;
}

chatInput.value = "";
```

});
}

// -------------------------
// Delegation Logic
// -------------------------

async function sendDelegation(description) {
const res = await fetch("/api/delegate-task", {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({ description }),
});

if (!res.ok) {
throw new Error(`HTTP ${res.status}`);
}

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
  const id = result.id ?? "n/a";
  const status = result.status ?? "queued";
  appendDelegationLog(`Delegated ✓ (id: ${id}, status: ${status})`);

  if (chatOutput) {
    chatOutput.innerHTML = `<pre>${JSON.stringify(result, null, 2)}</pre>`;
  }
} catch (err) {
  appendDelegationLog(`Delegation error: ${String(err)}`);
}

delegationInput.value = "";
```

});
}
