export async function loadSystemChronicle() {
  const res = await fetch("/chronicle/list");
  const data = await res.json();
  const el = document.getElementById("system-chronicle");
  el.innerHTML = data.map((e:any) =>
    `<div>[${e.timestamp}] ${e.event}</div>`
  ).join("");
}
