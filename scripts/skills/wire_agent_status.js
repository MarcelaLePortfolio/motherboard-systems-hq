import fs from "fs";
import path from "path";
import fetch from "node-fetch";

export default async function run(params = {}, ctx = {}) {
  try {
    const response = await fetch("http://localhost:3001/agents/status");
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();

    const dashboardPath = path.join(process.cwd(), "public", "dashboard.html");
    let html = fs.readFileSync(dashboardPath, "utf8");

    html = html.replace(
      /<div id="agent-status-container">[\\s\\S]*?<\/div>/,
      `<div id="agent-status-container">
        ${data
          .map(
            (agent) => `
          <div class="agent-card">
            <h3>${agent.name}</h3>
            <p>Status: ${agent.status}</p>
            <p>PID: ${agent.pid || "N/A"}</p>
            <p>Uptime: ${agent.uptime || "N/A"}</p>
          </div>`
          )
          .join("\n")}
      </div>`
    );

    fs.writeFileSync(dashboardPath, html, "utf8");
    return { executed: true, message: "Agent status wiring complete" };
  } catch (err) {
    return { executed: false, error: err.message };
  }
}
