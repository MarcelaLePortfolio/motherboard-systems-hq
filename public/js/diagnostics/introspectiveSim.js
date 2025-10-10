export async function loadIntrospectiveSim() {
  const res = await fetch("/introspect/history");
  const data = await res.json();
  const el = document.getElementById("introspective-sim");
  el.innerHTML = data.map(
    (r:any) => `<div>Scenario ${r.id}: ${r.success}% success, ${r.risk}% risk</div>`
  ).join("");
}
