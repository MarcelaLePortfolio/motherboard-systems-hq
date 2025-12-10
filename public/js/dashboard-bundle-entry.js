function $(id) {
return document.getElementById(id);
}

// -------------------------
// OPS Pill – SSE Wiring
// -------------------------

var opsPill =
$("ops-status-pill") || $("ops-pill") || $("ops-status");

if (opsPill && typeof window !== "undefined" && window.EventSource) {
try {
var opsSource = new EventSource("/events/ops");

```
opsPill.textContent = "OPS: Unknown";

opsSource.onmessage = function (ev) {
  try {
    var data = ev.data ? JSON.parse(ev.data) : {};
    var status =
      data.status ||
      data.state ||
      data.opsStatus ||
      "Online";

    opsPill.textContent = "OPS: " + status;

    // Debug helpers for DevTools
    window.lastOpsHeartbeat = Date.now();
    window.lastOpsStatusSnapshot = data;
  } catch (e) {
    console.warn("[OPS SSE] Parse error:", e);
    opsPill.textContent = "OPS: Unknown";
  }
};

opsSource.onerror = function (err) {
  console.warn("[OPS SSE] Error:", err);
  opsPill.textContent = "OPS: Unknown";
};
```

} catch (e) {
console.warn("[OPS SSE] EventSource setup failed:", e);
opsPill.textContent = "OPS: Unknown";
}
}

// -------------------------
// Matilda Chat Logic
// -------------------------

var chatForm = $("matilda-chat-form");
var chatInput = $("matilda-chat-input");
var chatOutput = $("project-viewport-output");

async function sendChat(message) {
var res = await fetch("/api/chat", {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({ message: message, agent: "matilda" }),
});

if (!res.ok) {
throw new Error("HTTP " + res.status);
}

var data = await res.json();
return data.response || JSON.stringify(data, null, 2);
}

if (chatForm && chatInput && chatOutput) {
chatForm.addEventListener("submit", function (e) {
e.preventDefault();
var text = chatInput.value.trim();
if (!text) return;

```
chatOutput.innerHTML = "<p><em>Matilda is thinking…</em></p>";

sendChat(text)
  .then(function (reply) {
    chatOutput.innerHTML =
      '<div class="matilda-reply">' + reply + "</div>";
  })
  .catch(function (err) {
    chatOutput.innerHTML =
      '<p style="color:red;">Chat error: ' + String(err) + "</p>";
  });

chatInput.value = "";
```

});
}

// -------------------------
// Delegation Logic
// -------------------------

var delegationForm =
$("task-delegation-form") || $("delegation-form");
var delegationInput =
$("task-delegation-input") || $("delegation-input") || chatInput;
var delegationLog =
$("task-delegation-log") || $("delegation-log");

async function sendDelegation(description) {
var res = await fetch("/api/delegate-task", {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({ description: description }),
});

if (!res.ok) {
throw new Error("HTTP " + res.status);
}

var data = await res.json();
return data;
}

function appendDelegationLog(entryText) {
if (!delegationLog) return;
var item = document.createElement("div");
item.className = "delegation-entry";
item.textContent = entryText;
delegationLog.prepend(item);
}

if (delegationForm && delegationInput) {
delegationForm.addEventListener("submit", function (e) {
e.preventDefault();
var text = delegationInput.value.trim();
if (!text) return;

```
appendDelegationLog("Delegating: " + text);

sendDelegation(text)
  .then(function (result) {
    var id = result.id != null ? result.id : "n/a";
    var status = result.status != null ? result.status : "queued";
    appendDelegationLog(
      "Delegated \u2713 (id: " + id + ", status: " + status + ")"
    );

    if (chatOutput) {
      chatOutput.innerHTML =
        "<pre>" + JSON.stringify(result, null, 2) + "</pre>";
    }
  })
  .catch(function (err) {
    appendDelegationLog("Delegation error: " + String(err));
  });

delegationInput.value = "";
```

});
}
