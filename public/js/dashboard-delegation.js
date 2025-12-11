// Phase 11 v11.10 – Dashboard Task Delegation wiring
// Uses existing DOM ids:
// - #delegation-input
// - #delegation-submit

console.log("[dashboard-delegation] module loaded");

function getSafeFetch() {
// Prefer the global fetch; log its type so we can understand runtime issues.
var f = (typeof fetch !== "undefined" ? fetch : (typeof window !== "undefined" ? window.fetch : undefined));
var t = typeof f;
console.log("[dashboard-delegation] detected fetch type:", t);

if (t !== "function") {
console.error("[dashboard-delegation] fetch is not a function; value:", f);
return null;
}
return f;
}

async function handleDelegationClick(e) {
if (e && e.preventDefault) e.preventDefault();

var input = document.getElementById("delegation-input");
if (!input) {
console.warn("[dashboard-delegation] delegation input not found at click time");
return;
}

var value = input.value || "";
if (!value.trim()) {
console.warn("[dashboard-delegation] empty delegation input; skipping");
return;
}

console.log("[dashboard-delegation] sending delegation:", value);

var safeFetch = getSafeFetch();
if (!safeFetch) {
console.error("[dashboard-delegation] aborting delegation because fetch is unavailable or invalid");
return;
}

try {
var res = await safeFetch("/api/delegate-task", {
method: "POST",
headers: {
"Content-Type": "application/json",
},
body: JSON.stringify({ description: value }),
});

```
var data;
try {
  data = await res.json();
} catch (parseErr) {
  data = { error: "Non-JSON response from /api/delegate-task" };
}

console.log("[dashboard-delegation] delegation response:", data);
```

} catch (err) {
console.error("[dashboard-delegation] delegation error:", err);
}
}

function initDashboardDelegation() {
var btn = document.getElementById("delegation-submit");
var input = document.getElementById("delegation-input");

if (!btn || !input) {
console.warn("[dashboard-delegation] delegation button or input not found in init");
return;
}

if (btn.dataset.delegationWired === "true") {
return; // avoid double-wiring
}
btn.dataset.delegationWired = "true";

btn.addEventListener("click", handleDelegationClick);

console.log("[dashboard-delegation] Task Delegation wiring active");
}

if (document.readyState === "loading") {
document.addEventListener("DOMContentLoaded", initDashboardDelegation);
} else {
initDashboardDelegation();
}
