// <0001fb01> Local SSE server for OPS — port 3201
import * as http from "http";
const PORT = 3201;
const ROUTE = "/events/ops";
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
            type: "ops_boot",
            message: "OPS SSE online.",
            timestamp: new Date().toISOString()
        });
        const interval = setInterval(() => {
            send(res, {
                type: "ops_heartbeat",
                status: "idle",
                actor: "system",
                timestamp: new Date().toISOString()
            });
        }, 5000);
        req.on("close", () => clearInterval(interval));
        return;
    }
    res.writeHead(404);
    res.end("Not Found");
})
    .listen(PORT, () => console.log(`<0001fb01> ops SSE listening at http://localhost:${PORT}${ROUTE}`));
