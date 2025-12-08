import http from "http";
import { exec } from "child_process";

const PORT = process.env.OPS_SSE_PORT || 3201;
const PATH = "/events/ops";

function getPm2StatusSnapshot() {
return new Promise((resolve, reject) => {
exec("pm2 jlist", (err, stdout) => {
if (err) {
return reject(err);
}

  try {
    const raw = JSON.parse(stdout);
    const processes = raw.map((proc) => ({
      name: proc.name,
      status: (proc.pm2_env && proc.pm2_env.status) || "unknown",
      restart_count:
        proc.pm2_env && typeof proc.pm2_env.restart_time === "number"
          ? proc.pm2_env.restart_time
          : 0,
      cpu:
        proc.monit && typeof proc.monit.cpu === "number"
          ? proc.monit.cpu
          : 0,
      memory:
        proc.monit && typeof proc.monit.memory === "number"
          ? proc.monit.memory
          : 0,
    }));

    resolve({
      type: "pm2-status",
      timestamp: Math.floor(Date.now() / 1000),
      processes,
    });
  } catch (parseErr) {
    reject(parseErr);
  }
});


});
}

function sendEvent(res, eventName, payload) {
try {
res.write("event: " + eventName + "\n");
res.write("data: " + JSON.stringify(payload) + "\n\n");
} catch (err) {
console.error("[OPS SSE] Error writing SSE event:", err);
}
}

const server = http.createServer((req, res) => {
if (req.url !== PATH) {
res.writeHead(404, { "Content-Type": "text/plain" });
res.end("Not found");
return;
}

res.writeHead(200, {
"Content-Type": "text/event-stream",
"Cache-Control": "no-cache",
Connection: "keep-alive",
"Access-Control-Allow-Origin": "*",
});

const clientId = Date.now();
console.log("[OPS SSE] client connected: " + clientId);

// Initial hello event
sendEvent(res, "hello", {
type: "hello",
source: "ops-sse",
timestamp: Math.floor(Date.now() / 1000),
message: "OPS SSE connected",
});

// Heartbeat every 5 seconds
const heartbeatInterval = setInterval(() => {
sendEvent(res, "heartbeat", {
type: "heartbeat",
timestamp: Math.floor(Date.now() / 1000),
message: "OPS SSE alive",
});
}, 5000);

// PM2 status snapshot every 15 seconds
const pm2Interval = setInterval(() => {
getPm2StatusSnapshot()
.then((snapshot) => {
sendEvent(res, "pm2-status", snapshot);
})
.catch((err) => {
console.error("[OPS SSE] Error fetching PM2 status:", err);
sendEvent(res, "ops-error", {
type: "ops-error",
source: "pm2-status",
timestamp: Math.floor(Date.now() / 1000),
message: "Failed to read pm2 jlist",
detail: err && err.message ? err.message : String(err),
});
});
}, 15000);

const cleanUp = () => {
clearInterval(heartbeatInterval);
clearInterval(pm2Interval);
console.log("[OPS SSE] client disconnected: " + clientId);
};

req.on("close", cleanUp);
req.on("end", cleanUp);
req.on("error", (err) => {
console.error("[OPS SSE] request error:", err);
cleanUp();
});
});

server.listen(PORT, () => {
console.log("[OPS SSE] listening on http://localhost
:" + PORT + PATH);
});
