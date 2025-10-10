export async function loadSystemHealth() {
  const res = await fetch("/system/health");
  const data = await res.json();
  const el = document.getElementById("system-health");
  el.innerHTML = Object.entries(data).map(
    ([k,v]) => `<div>${k}: <b>${v}</b></div>`
  ).join("");
}
