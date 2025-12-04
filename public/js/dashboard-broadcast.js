// <0001fad7> Phase 5.1 — Matilda → Cade → Effie Broadcast Visualization
// Wrapped in a guarded init() so we don't create duplicate intervals on reload.

const BROADCAST_GUARD_KEY = "__broadcastVisualizationInited";

const nodes = ["Matilda", "Cade", "Effie"];

function renderBroadcastNodes() {
const container = document.getElementById("broadcast-visual");
if (!container) return;

container.innerHTML = nodes
.map(
(n, i) =>
`<div class="node" id="node-${n}">${n}</div>${
          i < nodes.length - 1 ? '<div class="arrow">➜</div>' : ""
        }`
)
.join("");
}

function startBroadcastCycle() {
let idx = 0;

setInterval(() => {
const allNodes = document.querySelectorAll(".node");
allNodes.forEach((n) => n.classList.remove("active"));

```
const active = document.getElementById(`node-${nodes[idx]}`);
if (active) active.classList.add("active");

idx = (idx + 1) % nodes.length;
```

}, 1500);
}

/**

* Initialize the broadcast visualization in a guarded way so it
* does not re-register intervals or duplicate DOM nodes.
  */
  export function initBroadcastVisualization() {
  if (typeof window === "undefined" || typeof document === "undefined") {
  return;
  }

if (window[BROADCAST_GUARD_KEY]) {
return;
}
window[BROADCAST_GUARD_KEY] = true;

const run = () => {
renderBroadcastNodes();
startBroadcastCycle();
};

if (document.readyState === "loading") {
window.addEventListener("DOMContentLoaded", run);
} else {
run();
}
}

// Optional: expose for manual debugging in the browser console
if (typeof window !== "undefined") {
window.initBroadcastVisualization = initBroadcastVisualization;
}
