export async function loadPersistentInsight() {
  const res = await fetch("/insight/persist");
  const data = await res.json();
  const el = document.getElementById("persistent-insight");
  el.innerHTML = data.map((d:any) =>
    `<div class='entry'><b>${d.title}</b>: ${d.detail}</div>`
  ).join("") || "<em>No insights yet</em>";
}
