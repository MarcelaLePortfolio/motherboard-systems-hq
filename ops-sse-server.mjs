import http from "http";
import { exec } from "child_process";

const PORT = Number(process.env.OPS_SSE_PORT || 3201);
const PATH = "/events/ops";

function nowTs() {
return Math.floor(Date.now() / 1000);
}

function getPm2StatusSnapshot() {
return new Promise((resolve, reject) => {
exec("pm2 jlist", (err, stdout) => {
if (err) {
return reject(err);
}

  try {
    const raw = JSON.parse(stdout);
    const list = Array.isArray(raw) ? raw : [];
    const processes = list.map((p) => {
      const name =
        p && typeof p.name === "string" ? p.name : "unknown";
      const status =
        p &&
        p.pm2_env &&
        typeof p.pm2_env.status === "string"
          ? p.pm2_env.status
          : "unknown";
      const restartCount =
        p &&
        p.pm2_env &&
        typeof p.pm2_env.restart_time === "number"
          ? p.pm2_env.restart_time
          : 0;
      const cpu =
        p &&
        p.monit &&
        typeof p.monit.cpu === "number"
          ? p.monit.cpu
          : 0;
      const memory =
        p &&
        p.monit &&
        typeof p.monit.memory === "number"
          ? p.monit.memory
          : 0;

      return {
        name: name,
        status: status,
        restart_count: restartCount,
        cpu: cpu,
        memory: memory,
      };
    });

    resolve({
      type: "pm2-status",
      timestamp: nowTs(),
      processes: processes,
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

sendEvent(res, "hello", {
type: "hello",
source: "ops-sse",
timestamp: nowTs(),
message: "OPS SSE connected",
});

const heartbeatInterval = setInterval(() => {
sendEvent(res, "heartbeat", {
type: "heartbeat",
timestamp: nowTs(),
message: "OPS SSE alive",
});
}, 5000);

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
timestamp: nowTs(),
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
" + ":" + PORT + PATH);
});
