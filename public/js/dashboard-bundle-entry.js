// Phase 11 v11.10 – Minimal unified dashboard bundle
// Goal: Wire Matilda Chat + Task Delegation through bundled JS, update Project Visual Output,
// and keep OPS pill harmless (static) with no SSE dependencies.

(function () {
function onReady(fn) {
if (document.readyState === "loading") {
document.addEventListener("DOMContentLoaded", fn);
} else {
fn();
}
}

function getProjectOutputElement() {
// Try several reasonable selectors; fall back gracefully.
return (
document.getElementById("project-visual-output-pre") ||
document.querySelector("#project-visual-output pre") ||
document.querySelector("#project-visual-output code") ||
document.querySelector("[data-role='project-visual-output'] pre") ||
null
);
}

function appendToProjectOutput(title, payload) {
const el = getProjectOutputElement();
const text =
typeof payload === "string"
? payload
: JSON.stringify(payload, null, 2);

```
if (!el) {
  // Fallback: at least log to console so we can see something.
  console.log("[Project Visual Output]", title, payload);
  return;
}

const now = new Date();
const header = `[${now.toISOString()}] ${title}\n`;
const separator = "\n----------------------------------------\n";
const existing = el.textContent || "";

el.textContent = header + text + separator + existing;
```

}

async function sendMatildaChat(message) {
if (!message || !message.trim()) return;

```
appendToProjectOutput("Matilda Chat – Sending", { message });

try {
  const res = await fetch("/api/chat", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message,
      agent: "matilda",
    }),
  });

  const data = await res.json().catch(() => ({
    error: "Non-JSON response from /api/chat",
  }));

  appendToProjectOutput("Matilda Chat – Response", data);
} catch (err) {
  console.error("Matilda chat error:", err);
  appendToProjectOutput("Matilda Chat – Error", {
    error: String(err),
  });
}
```

}

async function sendTaskDelegation(description) {
if (!description || !description.trim()) return;

```
appendToProjectOutput("Task Delegation – Sending", { description });

try {
  // NOTE: Endpoint name is inferred from previous phases; adjust if needed.
  const res = await fetch("/api/delegate-task", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      description,
    }),
  });

  const data = await res.json().catch(() => ({
    error: "Non-JSON response from /api/delegate-task",
  }));

  appendToProjectOutput("Task Delegation – Response", data);
} catch (err) {
  console.error("Task delegation error:", err);
  appendToProjectOutput("Task Delegation – Error", {
    error: String(err),
  });
}
```

}

function wireMatildaChat() {
// Heuristic: assume first form on the dashboard is Matilda Chat.
const forms = Array.from(document.querySelectorAll("form"));
if (!forms.length) return;

```
const chatForm = forms[0];
if (!chatForm) return;

// Prefer textarea, then text input, then any input.
const chatInput =
  chatForm.querySelector("textarea") ||
  chatForm.querySelector("input[type='text']") ||
  chatForm.querySelector("input:not([type])");

const chatButton =
  chatForm.querySelector("button[type='submit']") ||
  chatForm.querySelector("button");

const handler = function (event) {
  if (event) event.preventDefault();
  if (!chatInput) return;
  const value = chatInput.value;
  if (!value || !value.trim()) return;
  sendMatildaChat(value);
};

// Wire submit event.
chatForm.addEventListener("submit", function (e) {
  e.preventDefault();
  handler(e);
});

// Wire click if we have an explicit button.
if (chatButton) {
  chatButton.addEventListener("click", function (e) {
    e.preventDefault();
    handler(e);
  });
}
```

}

function wireTaskDelegation() {
// Heuristic: assume second form on the dashboard is Task Delegation.
const forms = Array.from(document.querySelectorAll("form"));
if (forms.length < 2) return;

```
const taskForm = forms[1];
if (!taskForm) return;

const taskInput =
  taskForm.querySelector("textarea") ||
  taskForm.querySelector("input[type='text']") ||
  taskForm.querySelector("input:not([type])");

const taskButton =
  taskForm.querySelector("button[type='submit']") ||
  taskForm.querySelector("button");

const handler = function (event) {
  if (event) event.preventDefault();
  if (!taskInput) return;
  const value = taskInput.value;
  if (!value || !value.trim()) return;
  sendTaskDelegation(value);
};

taskForm.addEventListener("submit", function (e) {
  e.preventDefault();
  handler(e);
});

if (taskButton) {
  taskButton.addEventListener("click", function (e) {
    e.preventDefault();
    handler(e);
  });
}
```

}

function initOpsPill() {
// Keep OPS pill present but static; no SSE wiring in v11.10.
const pill =
document.getElementById("ops-status-pill") ||
document.querySelector("[data-role='ops-pill']");
if (!pill) return;

```
const textEl =
  pill.querySelector(".ops-pill-text") || pill;

if (textEl && !textEl.dataset.opsInitialized) {
  textEl.textContent = "OPS: Unknown";
  textEl.dataset.opsInitialized = "true";
}
```

}

onReady(function () {
try {
initOpsPill();
} catch (e) {
console.error("initOpsPill error:", e);
}

```
try {
  wireMatildaChat();
} catch (e) {
  console.error("wireMatildaChat error:", e);
}

try {
  wireTaskDelegation();
} catch (e) {
  console.error("wireTaskDelegation error:", e);
}
```

});
})();
