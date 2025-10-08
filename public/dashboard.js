async function refreshInsightChart() {
  const res = await fetch("/visual/trends");
  const { trends } = await res.json();
  const ctx = document.getElementById("insightChart").getContext("2d");

  const data = trends.data.slice(-10);
  const labels = data.map(d => new Date(d.ts).toLocaleTimeString());
  const success = data.map(d => d.success);
  const risk = data.map(d => d.risk);
  const adaptations = trends.adaptations || [];

  ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

  // Success (green)
  ctx.beginPath();
  ctx.strokeStyle = "#00c853";
  ctx.lineWidth = 2;
  success.forEach((v, i) => {
    const x = (i / success.length) * ctx.canvas.width;
    const y = ctx.canvas.height - (v * ctx.canvas.height / 100);
    i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
  });
  ctx.stroke();

  // Risk (red)
  ctx.beginPath();
  ctx.strokeStyle = "#d50000";
  ctx.lineWidth = 2;
  risk.forEach((v, i) => {
    const x = (i / risk.length) * ctx.canvas.width;
    const y = ctx.canvas.height - (v * ctx.canvas.height / 100);
    i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
  });
  ctx.stroke();

  // Adaptation markers (orange dots)
  ctx.fillStyle = "#ff6d00";
  const totalWidth = ctx.canvas.width;
  adaptations.forEach((a) => {
    const ts = new Date(a.ts).getTime();
    const first = new Date(data[0]?.ts || 0).getTime();
    const last = new Date(data[data.length - 1]?.ts || 0).getTime();
    if (!first || !last || ts < first || ts > last) return;
    const x = ((ts - first) / (last - first)) * totalWidth;
    const y = ctx.canvas.height - 10;
    ctx.beginPath();
    ctx.arc(x, y, 4, 0, Math.PI * 2);
    ctx.fill();
  });

  // Legend
  ctx.fillStyle = "#333";
  ctx.font = "10px sans-serif";
  ctx.fillText("Success", 10, 10);
  ctx.fillText("Risk", 70, 10);
  ctx.fillText("Adaptation", 120, 10);
}

setInterval(refreshInsightChart, 7000);

async function refreshChroniclePanel() {
  try {
    const res = await fetch("/chronicle/list");
    const { log } = await res.json();
    const container = document.getElementById("chroniclePanel");
    if (!container) return;
    container.innerHTML = log
      .slice(-10)
      .map(l => `<div><strong>${new Date(l.ts).toLocaleTimeString()}</strong> — ${l.event}</div>`)
      .join("");
  } catch (err) {
    console.error("Chronicle refresh failed", err);
  }
}
setInterval(refreshChroniclePanel, 8000);
