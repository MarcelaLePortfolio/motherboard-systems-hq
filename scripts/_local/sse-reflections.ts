// <0001fb00> Local SSE server for reflections — port 3101
import * as http from "http";

const PORT = 3101;
const ROUTE = "/events/reflections";

function sseHeaders(res) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    "Connection": "keep-alive",
    "Access-Control-Allow-Origin": "*"
  });
}

function send(res, data) {
  res.write(`data: ${JSON.stringify(data)}\n\n`);
}

http
  .createServer((req, res) => {
    if (req.method === "GET" && req.url.startsWith(ROUTE)) {
      sseHeaders(res);

      send(res, {
        type: "reflection_boot",
        message: "Reflections SSE online.",
        timestamp: new Date().toISOString()
      });

      const interval = setInterval(() => {
        send(res, {
          type: "reflection_heartbeat",
          message: "Reflections SSE heartbeat",
          timestamp: new Date().toISOString()
        });
      }, 5000);

      req.on("close", () => clearInterval(interval));
      return;
    }

    res.writeHead(404);
    res.end("Not Found");
  })
  .listen(PORT, () =>
    console.log(
      `<0001fb00> reflections SSE listening at http://localhost:${PORT}${ROUTE}`
    )
  );
