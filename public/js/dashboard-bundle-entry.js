// Phase 11 v11.10 – Unified dashboard bundle
// Clean, conservative wiring for:
// - Matilda Chat
// - Task Delegation
// - Static OPS pill
// - Project Visual Output

(function () {
function getProjectOutputElement() {
return (
document.getElementById("project-visual-output-pre") ||
document.querySelector("#project-visual-output pre") ||
document.querySelector("#project-visual-output code") ||
document.querySelector("[data-role='project-visual-output'] pre") ||
null
);
}

function appendToProjectOutput(title, payload) {
var el = getProjectOutputElement();
var text =
typeof payload === "string"
? payload
: JSON.stringify(payload, null, 2);

```
var now = new Date();
var header =
  "[" + now.toISOString() + "] " + String(title || "") + "\n";
var separator = "\n----------------------------------------\n";
var existing = (el && el.textContent) || "";

if (!el) {
  console.log("[Project Visual Output]", header + text);
  return;
}

el.textContent = header + text + separator + existing;
```

}

async function sendMatildaChat(message) {
if (!message || !message.trim()) return;

```
appendToProjectOutput("Matilda Chat – Sending", { message: message });

try {
  var res = await fetch("/api/chat", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      message: message,
      agent: "matilda"
    })
  });

  var data;
  try {
    data = await res.json();
  } catch (e) {
    data = { error: "Non-JSON response from /api/chat" };
  }

  appendToProjectOutput("Matilda Chat – Response", data);
} catch (err) {
  console.error("Matilda chat error:", err);
  appendToProjectOutput("Matilda Chat – Error", {
    error: String(err)
  });
}
```

}

async function sendTaskDelegation(description) {
if (!description || !description.trim()) return;

```
appendToProjectOutput("Task Delegation – Sending", {
  description: description
});

try {
  var res = await fetch("/api/delegate-task", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      description: description
    })
  });

  var data;
  try {
    data = await res.json();
  } catch (e) {
    data = { error: "Non-JSON response from /api/delegate-task" };
  }

  appendToProjectOutput("Task Delegation – Response", data);
} catch (err) {
  console.error("Task delegation error:", err);
  appendToProjectOutput("Task Delegation – Error", {
    error: String(err)
  });
}
```

}

function findMatildaForm() {
var byId =
document.getElementById("matilda-chat-form") ||
document.querySelector("[data-role='matilda-chat-form']") ||
document.querySelector(".matilda-chat-form");
if (byId) return byId;

```
var forms = Array.prototype.slice.call(
  document.querySelectorAll("form")
);
return forms[0] || null;
```

}

function findTaskForm() {
var byId =
document.getElementById("task-delegation-form") ||
document.querySelector("[data-role='task-delegation-form']") ||
document.querySelector(".task-delegation-form");
if (byId) return byId;

```
var forms = Array.prototype.slice.call(
  document.querySelectorAll("form")
);
return forms[1] || null;
```

}

function wireMatildaChat() {
var chatForm = findMatildaForm();
if (!chatForm) {
console.warn("[Dashboard] Matilda chat form not found");
return;
}

```
var chatInput =
  chatForm.querySelector("#matilda-chat-input") ||
  chatForm.querySelector("textarea") ||
  chatForm.querySelector("input[type='text']") ||
  chatForm.querySelector("input:not([type])");

var chatButton =
  chatForm.querySelector("#matilda-chat-submit") ||
  chatForm.querySelector("button[type='submit']") ||
  chatForm.querySelector("button");

function handler(event) {
  if (event) event.preventDefault();
  if (!chatInput) return;
  var value = chatInput.value;
  if (!value || !value.trim()) return;
  sendMatildaChat(value);
}

chatForm.addEventListener("submit", function (e) {
  e.preventDefault();
  handler(e);
});

if (chatButton) {
  chatButton.addEventListener("click", function (e) {
    e.preventDefault();
    handler(e);
  });
}

console.log("[Dashboard] Matilda chat wired");
```

}

function wireTaskDelegation() {
var taskForm = findTaskForm();
if (!taskForm) {
console.warn("[Dashboard] Task delegation form not found");
return;
}

```
var taskInput =
  taskForm.querySelector("#task-delegation-input") ||
  taskForm.querySelector("textarea") ||
  taskForm.querySelector("input[type='text']") ||
  taskForm.querySelector("input:not([type])");

var taskButton =
  taskForm.querySelector("#task-delegation-submit") ||
  taskForm.querySelector("button[type='submit']") ||
  taskForm.querySelector("button");

function handler(event) {
  if (event) event.preventDefault();
  if (!taskInput) return;
  var value = taskInput.value;
  if (!value || !value.trim()) return;
  sendTaskDelegation(value);
}

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

console.log("[Dashboard] Task delegation wired");
```

}

function initOpsPill() {
var pill =
document.getElementById("ops-status-pill") ||
document.querySelector("[data-role='ops-pill']");
if (!pill) return;

```
var textEl = pill.querySelector(".ops-pill-text") || pill;

if (textEl && !textEl.dataset.opsInitialized) {
  if (!textEl.textContent || !textEl.textContent.trim()) {
    textEl.textContent = "OPS: Unknown";
  }
  textEl.dataset.opsInitialized = "true";
}
```

}

function initDashboardBundle() {
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

}

if (document.readyState === "loading") {
document.addEventListener("DOMContentLoaded", initDashboardBundle);
} else {
initDashboardBundle();
}
})();
