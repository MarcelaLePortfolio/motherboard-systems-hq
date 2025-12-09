/**
 * Phase 11 – Universal OPS Heartbeat Broadcaster
 * Injects heartbeat + PM2 status into the OPS SSE stream every few seconds.
 *
 * Safe to include regardless of backend structure.
 */

const { exec } = require("child_process");

const OPS_URL = "http://host.docker.internal:3201/push"; // your OPS SSE internal endpoint

function send(payload) {
  try {
    fetch(OPS_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    }).catch(() => {});
  } catch {}
}

// Heartbeat every 3 seconds
setInterval(() => {
  send({
    type: "heartbeat",
    timestamp: Math.floor(Date.now() / 1000),
  });
}, 3000);

// PM2 status every 5 seconds
setInterval(() => {
  exec("pm2 jlist", (err, stdout) => {
    if (err) return;

    try {
      const list = JSON.parse(stdout);
      send({
        type: "pm2-status",
        processes: list.map(p => ({
          name: p.name,
          status: p.pm2_env.status,
          pid: p.pid,
          cpu: p.monit.cpu,
          memory: p.monit.memory
        }))
      });
    } catch {}
  });
}, 5000);

console.log("OPS heartbeat broadcaster running.");
