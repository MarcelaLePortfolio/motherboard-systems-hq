// Phase 11 v11.10 – Dashboard Task Delegation wiring
// Uses existing DOM ids:
//   - #delegation-input
//   - #delegation-submit
//
// Notes on the "TypeError: "" is not a function" error:
//
// The browser is telling us that something we are calling like a function
// is actually the empty string "" at runtime. Given this module, the most
// likely culprits are:
//   - the fetch function itself, or
//   - the res.json method on the Response object.
//
// We already log the detected fetch type (and see "function"), so the next
// step is to:
//   - strongly guard around the fetch call itself, and
//   - log the shape of the Response object and the type of res.json
//     before we ever call res.json().
//
// This lets us understand *what* is turning into "" at runtime instead of
// a function, while avoiding unhandled TypeErrors.

console.log("[dashboard-delegation] module loaded");

function getSafeFetch() {
// Prefer the global fetch; log its type so we can understand runtime issues.
var f =
typeof fetch !== "undefined"
? fetch
: typeof window !== "undefined"
? window.fetch
: undefined;

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
console.warn(
"[dashboard-delegation] delegation input not found at click time"
);
return;
}

var value = input.value || "";
if (!value.trim()) {
console.warn(
"[dashboard-delegation] empty delegation input; skipping"
);
return;
}

console.log("[dashboard-delegation] sending delegation:", value);

var safeFetch = getSafeFetch();
if (!safeFetch) {
console.error(
"[dashboard-delegation] aborting delegation because fetch is unavailable or invalid"
);
return;
}

var res;
try {
res = await safeFetch("/api/delegate-task", {
method: "POST",
headers: {
"Content-Type": "application/json",
},
body: JSON.stringify({ description: value }),
});
} catch (fetchErr) {
console.error(
"[dashboard-delegation] fetch threw before response:",
fetchErr
);
return;
}

console.log(
"[dashboard-delegation] fetch returned:",
!!res,
res && res.constructor && res.constructor.name,
"json type:",
res && typeof res.json
);

var data;

// If res.json has been mutated to a non-function (e.g., a string ""),
// calling it would cause "TypeError: "" is not a function".
if (!res || typeof res.json !== "function") {
console.error(
"[dashboard-delegation] res.json is not a function; value:",
res && res.json
);
data = {
error: "res.json is not a function",
jsonType: typeof (res && res.json),
};
console.log(
"[dashboard-delegation] delegation response (fallback):",
data
);
return;
}

try {
data = await res.json();
} catch (parseErr) {
console.error(
"[dashboard-delegation] error parsing JSON response:",
parseErr
);
data = { error: "Non-JSON response from /api/delegate-task" };
}

console.log("[dashboard-delegation] delegation response:", data);
}

function initDashboardDelegation() {
var btn = document.getElementById("delegation-submit");
var input = document.getElementById("delegation-input");

if (!btn || !input) {
console.warn(
"[dashboard-delegation] delegation button or input not found in init"
);
return;
}

if (btn.dataset.delegationWired === "true") {
return; // avoid double-wiring
}
btn.dataset.delegationWired = "true";

btn.addEventListener("click", handleDelegationClick);

console.log(
"[dashboard-delegation] Task Delegation wiring active"
);
}

if (document.readyState === "loading") {
document.addEventListener("DOMContentLoaded", initDashboardDelegation);
} else {
initDashboardDelegation();
}
