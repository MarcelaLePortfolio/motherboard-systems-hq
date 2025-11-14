// <0001fad7> Phase 5.1 — Matilda → Cade → Effie Broadcast Visualization
const nodes = ["Matilda", "Cade", "Effie"];
const container = document.getElementById("broadcast-visual");
if (container) {
  container.innerHTML = nodes
    .map((n, i) => `<div class="node" id="node-${n}">${n}</div>${i < nodes.length - 1 ? '<div class="arrow">➜</div>' : ""}`)
    .join("");
  animateCycle();
}
function animateCycle() {
  let idx = 0;
  setInterval(() => {
    document.querySelectorAll(".node").forEach(n => n.classList.remove("active"));
    const active = document.getElementById(`node-${nodes[idx]}`);
    if (active) active.classList.add("active");
    idx = (idx + 1) % nodes.length;
  }, 1500);
}
