export async function loadCognitiveCohesion() {
  const res = await fetch("/cognitive/history");
  const data = await res.json();
  const el = document.getElementById("cognitive-cohesion");
  el.innerHTML = `<pre>${JSON.stringify(data.slice(-5), null, 2)}</pre>`;
}
