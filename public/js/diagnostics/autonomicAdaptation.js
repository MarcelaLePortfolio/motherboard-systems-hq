export async function loadAutonomicAdaptation() {
  const res = await fetch("/adaptation/history");
  const data = await res.json();
  const el = document.getElementById("autonomic-adaptation");
  el.innerHTML = data.map((a:any) =>
    `<div>${a.action} → ${a.value} (${a.timestamp})</div>`
  ).join("");
}
