// Phase 11 v11.10 – minimal dashboard Task Delegation wiring
// Uses existing DOM ids:
// - #delegation-input
// - #delegation-submit
// Goal: fire a POST to the delegation API when the button is clicked.

(function () {
function initDelegationWiring() {
var btn = document.getElementById("delegation-submit");
var input = document.getElementById("delegation-input");

```
if (!btn || !input) {
  console.warn("[delegation-wire] delegation button or input not found");
  return;
}

if (btn.dataset.delegationWired === "true") {
  return; // avoid double-wiring on hot reloads
}
btn.dataset.delegationWired = "true";

btn.addEventListener("click", async function (e) {
  e.preventDefault();

  var value = input.value || "";
  if (!value.trim()) {
    console.warn("[delegation-wire] empty delegation input; skipping");
    return;
  }

  console.log("[delegation-wire] sending delegation:", value);

  try {
    var res = await fetch("/api/delegate-task", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ description: value }),
    });

    var data;
    try {
      data = await res.json();
    } catch (parseErr) {
      data = { error: "Non-JSON response from /api/delegate-task" };
    }

    console.log("[delegation-wire] delegation response:", data);
  } catch (err) {
    console.error("[delegation-wire] delegation error:", err);
  }
});

console.log("[delegation-wire] Task Delegation wiring active");
```

}

if (document.readyState === "loading") {
document.addEventListener("DOMContentLoaded", initDelegationWiring);
} else {
initDelegationWiring();
}
})();
