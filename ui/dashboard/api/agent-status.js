/* eslint-disable import/no-commonjs */
import http from "http";
import fs from "fs";
import url from "url";

const PORT = 3081;

function getStatus() {
  const log = fs.readFileSync("ui/dashboard/ticker-events.log", "utf-8")
    .trim()
    .split(
")
    .slice(-50)
    .map(line => JSON.parse(line));

  const latest = { cade: "offline", effie: "offline", matilda: "offline" };
  for (let i = log.length - 1; i >= 0; i--) {
    const ev = log[i];
    if (ev.event === "agent-online" && latest[ev.agent] === "offline") {
      latest[ev.agent] = "online";
    }
  }

  return { ...latest, timestamp: Math.floor(Date.now() / 1000) };
}

const server = http.createServer((req, res) => {
  const parsed = url.parse(req.url, true);

  // ✅ Add CORS headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(200);
    res.end();
    return;
  }

  if (parsed.pathname === "/ticker") {
    const log = fs.readFileSync("ui/dashboard/ticker-events.log", "utf-8")
      .trim()
      .split(
")
      .slice(-20)
      .map(line => JSON.parse(line));
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(log));
  } else {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(getStatus()));
  }
});

server.listen(PORT, () =>
  console.log(`✅ Status & Ticker API running with CORS at http://localhost:${PORT}`)
);
