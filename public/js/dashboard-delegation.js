// Phase 11 v11.10 – Dashboard Task Delegation wiring
// Uses existing DOM ids:
// - #delegation-input
// - #delegation-submit

console.log("[dashboard-delegation] module loaded");

async function handleDelegationClick(e) {
if (e && e.preventDefault) e.preventDefault();

const input = document.getElementById("delegation-input");
if (!input) {
console.warn("[dashboard-delegation] delegation input not found at click time");
return;
}

const value = input.value || "";
if (!value.trim()) {
console.warn("[dashboard-delegation] empty delegation input; skipping");
return;
}

console.log("[dashboard-delegation] sending delegation:", value);

try {
const res = await fetch("/api/delegate-task", {
method: "POST",
headers: {
"Content-Type": "application/json",
},
body: JSON.stringify({ description: value }),
});

```
let data;
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
const btn = document.getElementById("delegation-submit");
const input = document.getElementById("delegation-input");

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
