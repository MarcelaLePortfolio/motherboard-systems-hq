export async function drawInsightVisualizer() {
  const res = await fetch("/visual/trends");
  const data = await res.json();
  const el = document.getElementById("insight-visualizer");
  el.innerHTML = `<canvas id='insightChart' height='120'></canvas>`;
  // TODO: use Chart.js or Recharts in future, placeholder only
}
