function $(id) {
return document.getElementById(id);
}

/* -------------------------

OPS Pill – Static Only (SSE Disabled)

------------------------- */

var opsPill =
$("ops-status-pill") || $("ops-pill") || $("ops-status");

if (!opsPill && typeof document !== "undefined") {
var opsContainer =
document.querySelector(".ops-pill-container") || document.body;

if (opsContainer) {
opsPill = document.createElement("div");
opsPill.id = "ops-status-pill";
opsPill.className = "ops-pill";
opsPill.textContent = "OPS: Unknown";
if (opsContainer.firstChild) {
opsContainer.insertBefore(opsPill, opsContainer.firstChild);
} else {
opsContainer.appendChild(opsPill);
}
}
}

if (opsPill) {
opsPill.textContent = "OPS: Unknown";
}

/* -------------------------

Matilda Chat Logic

------------------------- */

var chatForm = $("matilda-chat-form");
var chatInput = $("matilda-chat-input");
var chatOutput = $("project-viewport-output");

// Fallback: if the input exists but the form does not have an ID, use its owning form
if (!chatForm && chatInput && chatInput.form) {
chatForm = chatInput.form;
}

// Fallback: if output container is missing, create one inside the visual output card
if (!chatOutput && typeof document !== "undefined") {
var outputHost =
$("project-visual-output-card") ||
document.querySelector(".project-viewport-inner") ||
document.body;

if (outputHost) {
chatOutput = document.createElement("div");
chatOutput.id = "project-viewport-output";
chatOutput.className = "project-viewport-output";
outputHost.appendChild(chatOutput);
}
}

function sendChat(message) {
return fetch("/api/chat", {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({ message: message, agent: "matilda" }),
})
.then(function (res) {
if (!res.ok) {
throw new Error("HTTP " + res.status);
}
return res.json();
})
.then(function (data) {
return data.response || JSON.stringify(data, null, 2);
});
}

if (chatForm && chatInput && chatOutput) {
chatForm.addEventListener("submit", function (e) {
e.preventDefault();
var text = chatInput.value.trim();
if (!text) return;

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


});
}

/* -------------------------

Delegation Logic

------------------------- */

var delegationForm =
$("task-delegation-form") || $("delegation-form");
var delegationInput =
$("task-delegation-input") || $("delegation-input") || chatInput;
var delegationLog =
$("task-delegation-log") || $("delegation-log");

// Fallback: if the input exists but form lacks ID, use its owning form
if (!delegationForm && delegationInput && delegationInput.form) {
delegationForm = delegationInput.form;
}

// Fallback: create a delegation log container if missing
if (!delegationLog && typeof document !== "undefined") {
var delegationHost =
$("delegation-card") || document.body;

if (delegationHost) {
delegationLog = document.createElement("div");
delegationLog.id = "task-delegation-log";
delegationLog.className = "task-delegation-log";
delegationHost.appendChild(delegationLog);
}
}

function sendDelegation(description) {
return fetch("/api/delegate-task", {
method: "POST",
headers: { "Content-Type": "application/json" },
body: JSON.stringify({ description: description }),
})
.then(function (res) {
if (!res.ok) {
throw new Error("HTTP " + res.status);
}
return res.json();
});
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

appendDelegationLog("Delegating: " + text);

sendDelegation(text)
  .then(function (result) {
    var id = result.id != null ? result.id : "n/a";
    var status = result.status != null ? result.status : "queued";
    appendDelegationLog(
      "Delegated ✓ (id: " + id + ", status: " + status + ")"
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


});
}
